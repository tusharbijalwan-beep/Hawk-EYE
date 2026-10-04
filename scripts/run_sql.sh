#!/bin/bash
# Run genuinely new, arbitrary SQL directly against a Superset-connected
# warehouse via SQL Lab's REST API — not limited to what an existing saved
# chart's query_context already computes. Confirmed working 2026-10-04 against
# database_id 8 (Cefi-SQL-Endpoint-Analysis), which resolves the same
# dev_cefi.* / dev_acquisition.* etc. schemas the dashboards themselves query
# (confirmed: a true calendar-month GROUP BY against
# dev_cefi.cube_onboarding_funnels returned real data, not a permission error).
#
# Usage: run_sql.sh "<SQL>" [database_id]
#   database_id: optional, defaults to 8 (Cefi-SQL-Endpoint-Analysis) — the
#     only database confirmed so far to both expose_in_sqllab and resolve the
#     schemas the main dashboards use. Run `run_sql.sh --list-databases` to see
#     every database this account can reach and whether it's SQL-Lab-exposed;
#     re-verify a new database_id the same way (a trivial `SELECT 1`, then a
#     real table read) before trusting it for real queries.
#
# Outputs JSON on stdout: {status, rows, columns, data, sql, error}
#
# Gotchas, both confirmed by direct testing — don't rediscover these:
#   1. `client_id` must be <=11 characters. Longer values fail with an opaque
#      500 (a varchar(11) column in Superset's own query-log table, not your
#      query's fault) — this script generates a random 10-char one for you.
#   2. Build the JSON payload with Python/jq, never hand-rolled shell string
#      interpolation — SQL containing single quotes (very common: date
#      literals, string comparisons) breaks naive bash quoting silently or
#      produces a generic 400 with no useful message.
#
# This bypasses the chart-query safety net entirely (no auto `caution`
# flagging, no known-bug warnings) — you ARE the query now, so apply the same
# discipline a chart author would: COUNT(DISTINCT ...) not COUNT(...) when you
# mean unique users, watch for fan-out joins, and cross-check a surprising
# number against an existing trusted chart before reporting it as fact.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

if [ "${1:-}" = "--list-databases" ]; then
  COOKIE=$(hawkeye_ensure_session) || exit 1
  curl -s -G -b "$COOKIE" "$HAWKEYE_BASE/api/v1/database/" --data-urlencode "q=(page_size:50)" \
    | python3 -c "
import json, sys
d = json.load(sys.stdin)
for r in d.get('result', []):
    print(json.dumps({'id': r.get('id'), 'name': r.get('database_name'), 'expose_in_sqllab': r.get('expose_in_sqllab')}))
"
  exit 0
fi

SQL="${1:?Usage: run_sql.sh \"<SQL>\" [database_id]  (or run_sql.sh --list-databases)}"
DATABASE_ID="${2:-8}"

COOKIE=$(hawkeye_ensure_session) || exit 1
CSRF=$(hawkeye_get_csrf "$COOKIE")
if [ -z "$CSRF" ]; then
  echo "ERROR: could not obtain CSRF token — session may have just expired." >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

CLIENT_ID="hk$(date +%s | tail -c 9)"  # <=11 chars total, see gotcha #1 above

# SQL goes through a file, never inline bash-to-python string interpolation —
# that's exactly the quoting trap gotcha #2 warns about.
printf '%s' "$SQL" > "$TMPDIR/query.sql"

DATABASE_ID="$DATABASE_ID" CLIENT_ID="$CLIENT_ID" TMPDIR="$TMPDIR" python3 -c "
import json, os
sql = open(os.environ['TMPDIR'] + '/query.sql').read()
payload = {
    'database_id': int(os.environ['DATABASE_ID']),
    'sql': sql,
    'schema': None,
    'tab': 'hawkeye',
    'tmp_table_name': '',
    'select_as_cta': False,
    'ctas_method': 'TABLE',
    'queryLimit': 1000,
    'expand_data': True,
    'client_id': os.environ['CLIENT_ID'],
}
json.dump(payload, open(os.environ['TMPDIR'] + '/payload.json', 'w'))
"

CODE=$(curl -s -o "$TMPDIR/out.json" -w "%{http_code}" \
  -b "$COOKIE" \
  -H "Content-Type: application/json" \
  -H "X-CSRFToken: $CSRF" \
  -H "Referer: $HAWKEYE_BASE/superset/welcome/" \
  -X POST "$HAWKEYE_BASE/api/v1/sqllab/execute/" \
  --data @"$TMPDIR/payload.json")

TMPDIR="$TMPDIR" python3 -c "
import json, os
d = json.load(open(os.environ['TMPDIR'] + '/out.json'))
orig_sql = open(os.environ['TMPDIR'] + '/query.sql').read()
if 'errors' in d:
    msg = d['errors'][0].get('message', str(d['errors']))
    print(json.dumps({'status': 'error', 'rows': None, 'columns': None, 'data': None, 'sql': orig_sql, 'error': msg}))
else:
    print(json.dumps({
        'status': d.get('status'),
        'rows': d.get('query', {}).get('rows'),
        'columns': [c.get('column_name') for c in d.get('columns', [])],
        'data': d.get('data'),
        'sql': d.get('query', {}).get('executedSql'),
        'error': d.get('query', {}).get('errorMessage'),
    }))
"

if [ "$CODE" != "200" ]; then
  exit 1
fi
