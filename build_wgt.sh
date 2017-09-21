#!/bin/sh

cp chromium_wgt/config.xml image/
wgtpkg-pack -f -o chromium_wgt/chromium.wgt image
