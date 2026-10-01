#!/bin/bash
# Search Superset's full chart catalog (9,973+ charts) by name, via the API —
# replaces the old manual UI search-box + pagination walk.
#
# Usage: search_charts.sh <keyword> [page_size]
# Outputs JSON array on stdout: [{id, name, dataset, dashboards: [...]}]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

KEYWORD="${1:?Usage: search_charts.sh <keyword> [page_size]}"
PAGE_SIZE="${2:-25}"

COOKIE=$(hawkeye_ensure_session) || exit 1

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Rison-encoded filter: slice_name contains <keyword>
Q="(filters:!((col:slice_name,opr:ct,value:'${KEYWORD}')),page_size:${PAGE_SIZE},order_column:changed_on_delta_humanized,order_direction:desc)"

CODE=$(curl -s -G -o "$TMPDIR/out.json" -w "%{http_code}" \
  -b "$COOKIE" \
  "$HAWKEYE_BASE/api/v1/chart/" \
  --data-urlencode "q=$Q")

if [ "$CODE" != "200" ]; then
  echo "ERROR: chart search failed with HTTP $CODE" >&2
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
            'name': r['slice_name'],
            'viz_type': r.get('viz_type'),
            'dataset': (r.get('datasource_name_text') or ''),
            'dashboards': [dd.get('dashboard_title') for dd in (r.get('dashboards') or [])],
            'last_modified': r.get('changed_on_delta_humanized'),
        }
        for r in d.get('result', [])
    ],
}
print(json.dumps(out, indent=2))
"
