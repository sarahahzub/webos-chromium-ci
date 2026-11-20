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
cp nss/nss-report.txt browser/abi-report.txt ipk/ 2>/dev/null || true
(cd ipk && sha256sum *.ipk > SHA256SUMS)
f=$(ls ipk/*.ipk)
{
	echo "## $V: $(basename "$f")"
	echo
	echo "| | |"
	echo "|---|---|"
	echo "| Source | [$REPO@${SHA:0:12}](https://github.com/$REPO/tree/$SHA) |"
	echo "| Size | $(stat -c %s "$f") bytes |"
	echo "| SHA-256 | \`$(sha256sum "$f" | cut -c1-64)\` |"
	echo "| browser.tar.zst | \`$(sha256sum browser/browser.tar.zst | cut -c1-64)\` |"
	echo
	echo "Verify: \`gh attestation verify $(basename "$f") -R $GITHUB_REPOSITORY\`"
} >> "$GITHUB_STEP_SUMMARY"
