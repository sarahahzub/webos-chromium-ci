#!/bin/bash
# host-setup.sh [SWAP_GB]: make room on a GitHub-hosted runner and create the fixed folders under /home/runner/cnci.
# Removes preinstalled tool chains the build does not use (about 35 GB), adds swap for the final link.
set -euo pipefail
sudo rm -rf /usr/local/lib/android /usr/share/dotnet /opt/ghc /usr/local/.ghcup /usr/lib/jvm /usr/lib/google-cloud-sdk \
	/usr/share/swift /opt/hostedtoolcache /usr/local/share/powershell /usr/local/share/chromium /opt/microsoft /opt/az \
	/usr/local/julia* 2>/dev/null || true
docker system prune -af > /dev/null 2>&1 || true
B=/home/runner/cnci
mkdir -p "$B/vol/snap" "$B/vol/logs" "$B/vol/artifacts/nss" "$B/work" "$B/nss"
if [ "${1:-0}" -gt 0 ]; then
	sudo fallocate -l "${1}G" /swap-cn && sudo chmod 600 /swap-cn && sudo mkswap -q /swap-cn && sudo swapon /swap-cn
fi
echo "CNB=$B" >> "$GITHUB_ENV"
nproc; free -g; df -h /
