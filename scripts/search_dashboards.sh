#!/bin/bash
# Search Superset's full dashboard catalog (169+ dashboards) by name, via the API.
#
# Usage: search_dashboards.sh <keyword> [page_size]
# Outputs JSON on stdout: {count, results: [{id, title, owners, last_modified}]}
# Pass an empty string as keyword to list everything, sorted by most-recently-modified
# (useful for the "what's actually live vs stale" recency pass).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

KEYWORD="${1:-}"
PAGE_SIZE="${2:-25}"

COOKIE=$(hawkeye_ensure_session) || exit 1

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

if [ -n "$KEYWORD" ]; then
  Q="(filters:!((col:dashboard_title,opr:ct,value:'${KEYWORD}')),page_size:${PAGE_SIZE},order_column:changed_on_delta_humanized,order_direction:desc)"
else
  Q="(page_size:${PAGE_SIZE},order_column:changed_on_delta_humanized,order_direction:desc)"
fi

CODE=$(curl -s -G -o "$TMPDIR/out.json" -w "%{http_code}" \
  -b "$COOKIE" \
  "$HAWKEYE_BASE/api/v1/dashboard/" \
  --data-urlencode "q=$Q")

if [ "$CODE" != "200" ]; then
  echo "ERROR: dashboard search failed with HTTP $CODE" >&2
  cat "$TMPDIR/out.json" >&2
  exit 1
fi

python3 -c "
import json
d = json.load(open('$TMPDIR/out.json'))
out = {
    'count': d.get('count'),
    'results': [
        {
            'id': r['id'],
            'title': r['dashboard_title'],
            'owners': [o.get('first_name','')+' '+o.get('last_name','') for o in (r.get('owners') or [])],
            'last_modified': r.get('changed_on_delta_humanized'),
            'status': r.get('status'),
        }
        for r in d.get('result', [])
    ],
}
print(json.dumps(out, indent=2))
"
