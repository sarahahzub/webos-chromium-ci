#!/bin/bash
# part-status.sh PART MAX_PART: after build.sh, read its status and decide what this job hands on.
#   done        -> browser artifact ready (status=completed)
#   out_of_time -> build folder checkpoint saved, the next job continues (status=running)
#   anything else, or still running in the last job -> fail
set -euo pipefail
B=/home/runner/cnci
P=$1 MAX=$2
s=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('status',''))" "$B/vol/logs/$BUILD_ID.json" 2>/dev/null || echo missing)
prog=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('last_progress',''))" "$B/vol/logs/$BUILD_ID.json" 2>/dev/null || true)
echo "build.sh status: $s, last progress $prog"
case "$s" in
done)
	[ -f "$B/vol/artifacts/$BUILD_ID/browser.tar.zst" ] || { echo "no browser.tar.zst"; exit 1; }
	echo "status=completed" >> "$GITHUB_OUTPUT" ;;
out_of_time)
	[ "$P" -lt "$MAX" ] || { echo "still not finished after $MAX jobs"; exit 1; }
	echo "status=running" >> "$GITHUB_OUTPUT" ;;
*) echo "build failed (status $s)"; exit 1 ;;
esac
df -h /
