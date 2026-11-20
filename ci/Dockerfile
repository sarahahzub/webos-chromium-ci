# Build container for the WebOS Chromium scripts (source/container/*.sh). The same contents as the Modal image in
# source/modalapp/build.py: Ubuntu 22.04, Python 3.12, the host tool libraries and ninja. The scripts expect
# /opt/cn (the source folder), /vol (snapshots, logs, artifacts) and /work (scratch); ci/crun.sh mounts them.
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive TZ=UTC
# i386: V8's snapshot tools for a 32-bit ARM target are i386 binaries (patch 0006 runs them under qemu-i386-static)
RUN dpkg --add-architecture i386 && apt-get update -qq && apt-get install -y -qq --no-install-recommends \
      qemu-user-static libc6:i386 libgcc-s1:i386 \
      libnss3 libnspr4 libglib2.0-0 libdbus-1-3 libexpat1 libfontconfig1 libfreetype6 libharfbuzz0b libxkbcommon0 \
      libwayland-client0 libdrm2 libgbm1 libasound2 libpulse0 libudev1 libxml2 libxslt1.1 \
      git curl ca-certificates xz-utils zstd unzip ccache squashfs-tools file binutils rsync patch pkg-config \
      lsb-release python3 python3-pip gperf bison flex dpkg-dev cmake wayland-protocols libwayland-bin tar procps \
      time gawk wget cpio bc binutils-arm-linux-gnueabi software-properties-common gpg-agent \
 && add-apt-repository -y ppa:deadsnakes/ppa && apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends python3.12 \
 && ln -sf /usr/bin/python3.12 /usr/local/bin/python3 && ln -sf /usr/bin/python3.12 /usr/local/bin/python \
 && rm -rf /var/lib/apt/lists/*
ARG NINJA_VERSION=1.12.1
RUN curl -fsSL -o /tmp/ninja.zip https://github.com/ninja-build/ninja/releases/download/v${NINJA_VERSION}/ninja-linux.zip \
 && unzip -o /tmp/ninja.zip -d /usr/local/bin && chmod 755 /usr/local/bin/ninja && rm /tmp/ninja.zip && ninja --version \
 && python3 --version
