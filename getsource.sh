#!/bin/sh
set -x
SRC_TAR=chromium-wayland-3ea904e.tar.xz

if [ ! -e ${SRC_TAR} ]; then
    wget https://tmp.igalia.com/chromium-tarballs/${SRC_TAR}
fi

tar -xf ${SRC_TAR}

patch < chromium_patch/api-keys.patch
cd src/
patch  -p1 < ../chromium_patch/0001-Rotate-gcc-toolchain-s-build-flags.patch
patch < ../chromium_patch/0004-Create-empty-i18n_process_css_test.html-file-to-avoi.patch
