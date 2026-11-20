#!/bin/bash
# prep-cn.sh VARIANT: copy the checked-out source/ (in ./wc) to /home/runner/cnci/cn, the folder mounted as /opt/cn.
# Only args.gn changes, and only in this copy:
#   all variants: cc_wrapper = "" (no ccache; the build folder itself carries the state from one job to the next)
#   armv8:        arm_arch = "armv8-a", arm_version = 8 (patch 0056: -mfpu=neon-fp-armv8, -mtune=cortex-a55)
set -euo pipefail
V=${1:?variant}
B=/home/runner/cnci
rm -rf "$B/cn"; cp -a "$GITHUB_WORKSPACE/wc/source" "$B/cn"
A=$B/cn/args.gn
grep -q '^cc_wrapper = "ccache"' "$A" || { echo "args.gn: no cc_wrapper line"; exit 1; }
sed -i 's/^cc_wrapper = "ccache".*/cc_wrapper = ""   # CI: no ccache (the build folder carries the state between jobs)/' "$A"
case "$V" in
default) ;;
armv8)
	grep -q '^arm_arch = "armv7-a"' "$A" && grep -q '^arm_version = 7$' "$A" || { echo "args.gn: arm lines not found"; exit 1; }
	sed -i 's/^arm_arch = "armv7-a".*/arm_arch = "armv8-a"   # CI armv8 variant/; s/^arm_version = 7$/arm_version = 8   # CI armv8 variant (patch 0056)/' "$A" ;;
*) echo "unknown variant $V"; exit 1 ;;
esac
echo "args.gn changes for variant $V:"
diff "$GITHUB_WORKSPACE/wc/source/args.gn" "$A" || true
