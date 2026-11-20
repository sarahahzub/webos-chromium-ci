#!/bin/bash
# crun.sh SCRIPT [ARGS...]: run source/container/SCRIPT in the build container with the paths the scripts expect.
set -euo pipefail
B=/home/runner/cnci
exec docker run --rm --shm-size=2g \
	-e BUILD_ID -e BUILD_JOBS -e CCACHE_SAVE_MIN \
	-v "$B/cn:/opt/cn" -v "$B/vol:/vol" -v "$B/work:/work" \
	cn-builder:ci bash "/opt/cn/container/$1" "${@:2}"
