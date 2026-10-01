#!/bin/bash
# Get a dashboard's full structure — title, owners, tabs, and every chart's
# id/name/tab — in ONE API call. No browser needed at all for this; this
# replaces the old "open the dashboard, click every tab, read data-test-chart-id
# off the DOM" shallow-indexing process entirely.
#
# Usage: fetch_dashboard.sh <dashboard_id>
# Outputs JSON: {id, title, owners, tabs: [name,...], charts: [{id, name, tab}]}

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

DASH_ID="${1:?Usage: fetch_dashboard.sh <dashboard_id>}"

COOKIE=$(hawkeye_ensure_session) || exit 1

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

CODE=$(curl -s -o "$TMPDIR/meta.json" -w "%{http_code}" -b "$COOKIE" "$HAWKEYE_BASE/api/v1/dashboard/$DASH_ID")
if [ "$CODE" != "200" ]; then
  echo "ERROR: dashboard metadata fetch for id $DASH_ID failed with HTTP $CODE" >&2
  cat "$TMPDIR/meta.json" >&2
  exit 1
fi

python3 -c "
import json

d = json.load(open('$TMPDIR/meta.json'))
r = d['result']
pj = json.loads(r['position_json']) if r.get('position_json') else {}

tab_name_by_id = {
    k: v.get('meta', {}).get('text')
    for k, v in pj.items()
    if isinstance(v, dict) and v.get('type') == 'TAB'
}

charts = []
for k, v in pj.items():
    if not (isinstance(v, dict) and v.get('type') == 'CHART'):
        continue
    meta = v.get('meta', {})
    # find the nearest TAB ancestor in this node's parents list
    tab_name = None
    for p in reversed(v.get('parents', [])):
        if p in tab_name_by_id:
            tab_name = tab_name_by_id[p]
            break
    charts.append({
        'id': meta.get('chartId'),
        'name': meta.get('sliceNameOverride') or meta.get('sliceName'),
        'tab': tab_name,
    })

out = {
    'id': r['id'],
    'title': r['dashboard_title'],
    'owners': [o.get('first_name','')+' '+o.get('last_name','') for o in (r.get('owners') or [])],
    'last_modified': r.get('changed_on_delta_humanized'),
    'tabs': list(dict.fromkeys(tab_name_by_id.values())),
    'chart_count': len(charts),
    'charts': charts,
}
print(json.dumps(out, indent=2))
"
