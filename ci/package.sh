#!/bin/bash
# package.sh VARIANT VERSION SOURCE_REPO SHA: browser/browser.tar.zst + launcher/cnrun + NSS -> ipk/<id>_<version>_arm.ipk
#   default: the normal app id and title from config.env
#   armv8:   its own app id and title, so it installs next to the normal app for comparison
set -euo pipefail
V=$1 VER=$2 REPO=$3 SHA=$4
S=$GITHUB_WORKSPACE/wc/source
(cd browser && sha256sum -c SHA256SUMS)
strings launcher/cnrun | grep -q "Press Back again to exit" || { echo "launcher looks wrong"; exit 1; }
rm -rf nss ipk; mkdir -p nss ipk
zstd -dc /home/runner/cnci/nss/nss.tar.zst | tar -C nss -xf - lib nss-report.txt
EXTRA=()
[ "$V" = armv8 ] && EXTRA=(--app-id io.github.sarahahzub.chromium.armv8 --title "Chromium Browser ARMv8")
python3 "$S/package/mkipk.py" --browser "$PWD/browser/browser.tar.zst" --version "$VER" --launcher "$PWD/launcher/cnrun" \
	--requires "glibc=2.24,webos=webOS 4.4" --lib-dir "$PWD/nss/lib" --out "$PWD/ipk" "${EXTRA[@]}"
# ipk/ holds only the IPK (artifact webos-chromium-<variant>); everything else goes to extra/, which the Result job
# puts into the logs artifact
rm -rf extra; mkdir -p extra
cp nss/nss-report.txt extra/; cp browser/abi-report.txt extra/ 2>/dev/null || true   # browser.tar.zst: inside the IPK, not kept separately
f=$(ls ipk/*.ipk)
sha256sum "$f" browser/browser.tar.zst | sed 's#  .*/#  #' > extra/SHA256SUMS
printf '| %s | `%s` | %s | `%s` |\n' "$V" "$(basename "$f")" "$(stat -c %s "$f" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta') bytes" "$(sha256sum "$f" | cut -c1-64)" > extra/ROW.md
cat extra/ROW.md
