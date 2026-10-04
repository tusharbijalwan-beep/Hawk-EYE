#!/bin/bash
# Fetch a Superset chart's real underlying data directly via the REST API —
# no browser rendering, no "View as table" UI dance, no per-chart reload.
#
# Usage: fetch_chart.sh <chart_id> [date_range] [--no-cache]
#   date_range: optional, "YYYY-MM-DD : YYYY-MM-DD" — filters server-side
#     instead of pulling full history and filtering client-side. Confirmed
#     working 2026-10-01 against the TEMPORAL_RANGE filter Superset charts use.
#     Omit to get full history (the chart's own default/"No filter" behavior).
#   --no-cache: bypass the response cache (default TTL 300s, see lib.sh).
#
# Outputs JSON on stdout: {chart_id, chart_name, viz_type, status, error,
#   rowcount, colnames, data, sql, caution} — `caution` is non-null when this
#   chart's dataset is on the known-fan-out-risk list (see KNOWN_RISKY_DATASETS
#   below) and its name looks like a percentage metric; cross-check against a
#   raw-count chart before trusting it when that field is present.
#
# On failure: prints an error to stderr and exits non-zero. Exit code 2 means
# "this chart has no query_context (unusual viz type) — fall back to the
# browser View-as-table method documented in SKILL.md", any other non-zero
# exit is a session/network problem.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

CHART_ID="${1:?Usage: fetch_chart.sh <chart_id> [date_range] [--no-cache]}"
shift
DATE_RANGE=""
NO_CACHE=0
for arg in "$@"; do
  if [ "$arg" = "--no-cache" ]; then
    NO_CACHE=1
  else
    DATE_RANGE="$arg"
  fi
done

# Datasource IDs confirmed 2026-10-01 to produce inflated/wrong percentages via
# a SQL fan-out (SUM(...)/COUNT(user_id) instead of COUNT(DISTINCT user_id)) —
# see dashboard-inventory.md's Onboarding dashboard section for the full
# writeup. Keyed by numeric datasource id (from query_context.datasource.id),
# not dataset name — the single-chart API doesn't return the name cheaply, and
# the id is already right there in query_context with no extra API call.
# datasource_id 1117 = dev_cefi.cube_onboarding_funnels (confirmed across
# charts 8453/8454/8456/8459/8462/8531). Add to this list as more are confirmed;
# don't remove entries without re-verifying.
KNOWN_RISKY_DATASOURCE_IDS="1117"

CACHE_KEY="chart_${CHART_ID}_$(echo "${DATE_RANGE:-full}" | tr -c 'a-zA-Z0-9' '_')"
if [ "$NO_CACHE" -eq 0 ]; then
  if CACHED=$(hawkeye_cache_get "$CACHE_KEY"); then
    echo "$CACHED"
    exit 0
  fi
fi

COOKIE=$(hawkeye_ensure_session) || exit 1

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

META_CODE=$(curl -s -o "$TMPDIR/meta.json" -w "%{http_code}" -b "$COOKIE" "$HAWKEYE_BASE/api/v1/chart/$CHART_ID")
if [ "$META_CODE" != "200" ]; then
  echo "ERROR: metadata fetch for chart $CHART_ID failed with HTTP $META_CODE" >&2
  cat "$TMPDIR/meta.json" >&2
  exit 1
fi

HAS_QC=$(python3 -c "
import json
d = json.load(open('$TMPDIR/meta.json'))
qc = d['result'].get('query_context')
print('yes' if qc else 'no')
if qc:
    qc_obj = json.loads(qc)
    date_range = '''$DATE_RANGE'''
    if date_range:
        for f in qc_obj.get('queries', [{}])[0].get('filters', []):
            if f.get('op') == 'TEMPORAL_RANGE':
                f['val'] = date_range
    open('$TMPDIR/qc.json','w').write(json.dumps(qc_obj))
")
CHART_NAME=$(python3 -c "import json; print(json.load(open('$TMPDIR/meta.json'))['result']['slice_name'])")
VIZ_TYPE=$(python3 -c "import json; print(json.load(open('$TMPDIR/meta.json'))['result']['viz_type'])")
DATASOURCE_ID=$(python3 -c "
import json
d = json.load(open('$TMPDIR/meta.json'))['result']
qc = json.loads(d['query_context']) if d.get('query_context') else {}
print(qc.get('datasource', {}).get('id', ''))
" 2>/dev/null || echo "")

if [ "$HAS_QC" = "no" ]; then
  echo "ERROR: chart $CHART_ID ('$CHART_NAME', viz_type=$VIZ_TYPE) has no query_context." >&2
  echo "  Fall back to the browser View-as-table method (SKILL.md's documented fallback extraction path)." >&2
  exit 2
fi

CSRF=$(hawkeye_get_csrf "$COOKIE")
if [ -z "$CSRF" ]; then
  echo "ERROR: could not obtain CSRF token — session may have just expired." >&2
  exit 1
fi

DATA_CODE=$(curl -s -o "$TMPDIR/data.json" -w "%{http_code}" \
  -b "$COOKIE" \
  -H "Content-Type: application/json" \
  -H "X-CSRFToken: $CSRF" \
  -H "Referer: $HAWKEYE_BASE/superset/welcome/" \
  -X POST "$HAWKEYE_BASE/api/v1/chart/data" \
  --data @"$TMPDIR/qc.json")

# Structural caution check — reads the chart's OWN executed SQL text and looks for the actual
# mismatch mechanism (SUM(...) numerator vs COUNT(DISTINCT ...) denominator), rather than guessing
# from the chart's name. Corrected 2026-10-04: an earlier version of this check keyed off whether
# the name started with "Signup", which works today but breaks the moment a chart gets renamed —
# this version reads the real SQL shape instead, which is what actually determines correctness.
# Deliberately still gated to KNOWN_RISKY_DATASOURCE_IDS, not applied to every dataset: a
# SUM(revenue)/COUNT(DISTINCT user_id) pattern is a completely normal, CORRECT way to compute AVPU
# on a table that doesn't fan out — this check only means something on a table already confirmed to
# duplicate rows per user. Applying it unscoped would flag a flood of perfectly fine metrics.
build_caution() {
  # SQL passed via a temp file, never inline bash-to-python interpolation — SQL text routinely
  # contains single quotes (date literals) which breaks naive substitution silently.
  local sql_file="$1"
  local dsid="$2"
  SQL_FILE="$sql_file" DSID="$dsid" RISKY_IDS="$KNOWN_RISKY_DATASOURCE_IDS" python3 -c "
import re, sys, os
sql = open(os.environ['SQL_FILE']).read()
dsid = os.environ['DSID']
risky = os.environ['RISKY_IDS'].split(',')
if not (dsid and dsid in risky and sql):
    sys.exit(0)
has_sum = bool(re.search(r'SUM\s*\(', sql, re.I))
has_distinct_count = bool(re.search(r'COUNT\s*\(\s*DISTINCT', sql, re.I))
has_plain_count = bool(re.search(r'COUNT\s*\(\s*(?!DISTINCT)\S', sql, re.I))
# Risky shape: a non-distinct SUM paired with a denominator that's ONLY ever COUNT(DISTINCT...) —
# no plain COUNT anywhere to confirm both sides match distinctness. This is the exact mechanism
# confirmed broken on 8458/8459/8461/8462/8543/8555/8556 (see dashboard-inventory.md).
if has_sum and has_distinct_count and not has_plain_count:
    print('This chart'+chr(39)+'s SQL pairs a non-distinct SUM numerator with a COUNT(DISTINCT...) denominator on a dataset with a confirmed row-fan-out bug — see dashboard-inventory.md (cube_onboarding_funnels section). This exact shape has been confirmed to inflate past 100% on other charts. Cross-check against two \"Signup to X\" absolute counts instead of trusting this value directly.')
"
}

if [ "$DATA_CODE" = "400" ]; then
  RESULT=$(python3 -c "
import json
try:
    body = json.load(open('$TMPDIR/data.json'))
    msg = body.get('message', json.dumps(body))
except Exception:
    msg = open('$TMPDIR/data.json').read()
out = {
    'chart_id': $CHART_ID,
    'chart_name': '''$CHART_NAME''',
    'viz_type': '''$VIZ_TYPE''',
    'status': 'error',
    'error': msg,
    'rowcount': None,
    'colnames': None,
    'data': None,
    'sql': None,
    'caution': None,
}
print(json.dumps(out))
")
  echo "$RESULT"
  [ "$NO_CACHE" -eq 0 ] && echo "$RESULT" | hawkeye_cache_set "$CACHE_KEY"
  exit 0
fi

if [ "$DATA_CODE" != "200" ]; then
  echo "ERROR: data fetch for chart $CHART_ID ('$CHART_NAME') failed with HTTP $DATA_CODE" >&2
  cat "$TMPDIR/data.json" >&2
  exit 1
fi

python3 -c "
import json
d = json.load(open('$TMPDIR/data.json'))
open('$TMPDIR/chart_sql.txt', 'w').write(d['result'][0].get('query') or '')
"
CAUTION=$(build_caution "$TMPDIR/chart_sql.txt" "$DATASOURCE_ID")

RESULT=$(python3 -c "
import json
d = json.load(open('$TMPDIR/data.json'))
r = d['result'][0]
out = {
    'chart_id': $CHART_ID,
    'chart_name': '''$CHART_NAME''',
    'viz_type': '''$VIZ_TYPE''',
    'status': r.get('status'),
    'error': r.get('error'),
    'rowcount': r.get('rowcount'),
    'colnames': r.get('colnames'),
    'data': r.get('data'),
    'sql': r.get('query'),
    'caution': '''$CAUTION''' or None,
}
print(json.dumps(out))
")
echo "$RESULT"
[ "$NO_CACHE" -eq 0 ] && echo "$RESULT" | hawkeye_cache_set "$CACHE_KEY"
