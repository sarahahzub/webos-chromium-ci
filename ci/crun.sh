#!/bin/bash
# crun.sh SCRIPT [ARGS...]: run source/container/SCRIPT in the build container with the paths the scripts expect.
# Afterwards the files in /vol (snapshots, logs, artifacts) belong to the runner user again: the container writes
# them as root, some with mode 600 (zstd), and the cache and artifact steps run as the runner user.
set -uo pipefail
B=/home/runner/cnci
docker run --rm --shm-size=2g \
	-e BUILD_ID -e BUILD_JOBS -e CCACHE_SAVE_MIN \
	-v "$B/cn:/opt/cn" -v "$B/vol:/vol" -v "$B/work:/work" \
	cn-builder:ci bash "/opt/cn/container/$1" "${@:2}"
rc=$?
sudo chown -R "$(id -u):$(id -g)" "$B/vol"
exit $rc
