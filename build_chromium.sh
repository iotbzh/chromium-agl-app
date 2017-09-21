#!/bin/sh
source /xdt/sdk/environment-setup-aarch64-agl-linux

SRC_REV="20170827.r497674.git3ea904e-dev0"

SRC_PKG=$(pwd)
SRC_BUILD=${SRC_PKG}/src
INST_PKG=${SRC_PKG}/image

SDK_SYSROOT=${SDKTARGETSYSROOT}
SDK_SYSROOT_NATIVE=${OECORE_NATIVE_SYSROOT}

# CHROMIUM_BUILD_TYPE ["Release", "Debug"]
CHROMIUM_BUILD_TYPE="Release"

CPUTARGET="arm64"
#AR=
#CC=
#CXX=

TARGET_CFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types -fdebug-prefix-map=${SRC_PKG}=/usr/src/debug/chromium/${SRC_REV} -fdebug-prefix-map=${OECORE_NATIVE_SYSROOT}= -fdebug-prefix-map=${SDKTARGETSYSROOT}=  -fstack-protector-strong -pie -fpie -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security"
TARGET_CPPFLAGS=""
TARGET_CXXFLAGS=" -O2 -pipe -g -feliminate-unused-debug-types -fdebug-prefix-map=${SRC_PKG}=/usr/src/debug/chromium/${SRC_REV} -fdebug-prefix-map=${OECORE_NATIVE_SYSROOT}= -fdebug-prefix-map=${SDKTARGETSYSROOT}=  -fstack-protector-strong -pie -fpie -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -Werror=format-security"
TARGET_LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed -fstack-protector-strong -Wl,-z,relro,-z,now"

BUILD_LD="ld "
BUILD_AR="ar"
BUILD_CPP="gcc  -E"
BUILD_CC="gcc "
BUILD_CXX="g++ "
BUILD_CFLAGS="-isystem${OECORE_NATIVE_SYSROOT}/usr/include -O2 -pipe"
BUILD_CXXFLAGS="-isystem${OECORE_NATIVE_SYSROOT}/usr/include"
BUILD_LDFLAGS="-L${OECORE_NATIVE_SYSROOT}/usr/lib -L${OECORE_NATIVE_SYSROOT}/lib -Wl,-rpath-link,${OECORE_NATIVE_SYSROOT}/usr/lib -Wl,-rpath-link,${OECORE_NATIVE_SYSROOT}/lib -Wl,-rpath,${OECORE_NATIVE_SYSROOT}/usr/lib -Wl,-rpath,${OECORE_NATIVE_SYSROOT}/lib -Wl,-O1"

STAGING_DIR_TARGET=${SDKTARGETSYSROOT}

EXTRA_OEGN=" \
        gold_path=\"\" \
        enable_nacl=false \
        is_clang=false \
        fatal_linker_warnings=false  \
        v8_use_external_startup_data=false \
        linux_use_bundled_binutils=false \
        use_gold=true \
        is_component_build=false \
        proprietary_codecs=false \
        use_ozone=true \
        use_jumbo_build = true \
        ozone_auto_platforms=false \
        ozone_platform_headless=true \
        enable_package_mash_services=true \
        ozone_platform_wayland=true \
        ozone_platform_x11=false \
        ozone_platform=\"wayland\" \
        v8_use_snapshot=false \
        use_kerberos=false \
        use_cups=false \
        use_gnome_keyring=false \
        treat_warnings_as_errors=false \
        target_cpu=\"${CPUTARGET}\" \
        target_os=\"linux\"  \
        host_toolchain=\"//build/toolchain/cros:host\" \
        custom_toolchain=\"//build/toolchain/cros:target\" \
        v8_snapshot_toolchain=\"//build/toolchain/cros:v8_snapshot\" \
        cros_host_is_clang=false \
        cros_target_ar=\"${AR}\" \
        cros_target_cc=\"${CC}\" \
        cros_target_cxx=\"${CXX}\" \
        cros_target_ld=\"${CXX}\" \
        cros_target_extra_cflags=\"${TARGET_CFLAGS}\" \
        cros_target_extra_ldflags=\"${TARGET_LDFLAGS}\" \
        cros_target_extra_cxxflags=\"${TARGET_CXXFLAGS}\" \
        cros_target_extra_cppflags=\"${TARGET_CPPFLAGS}\" \
        cros_v8_snapshot_ar=\"${BUILD_AR}\" \
        cros_v8_snapshot_cc=\"${BUILD_CPP}\" \
        cros_v8_snapshot_cxx=\"${BUILD_CXX}\" \
        cros_v8_snapshot_ld=\"${BUILD_CXX}\" \
        cros_v8_snapshot_extra_cflags=\"${BUILD_CFLAGS}\" \
        cros_v8_snapshot_extra_cxxflags=\"${BUILD_CXXFLAGS}\" \
        cros_v8_snapshot_extra_cppflags=\"${BUILD_CPPFLAGS}\" \
        cros_v8_snapshot_extra_ldflags=\"${BUILD_LDFLAGS}\" \
        cros_host_cc=\"${BUILD_CC}\" \
        cros_host_cxx=\"${BUILD_CXX}\" \
        cros_host_ar=\"${BUILD_AR}\" \
        cros_host_ld=\"${BUILD_CXX}\" \
        cros_host_extra_cflags=\"${BUILD_CFLAGS}\" \
        cros_host_extra_cxxflags=\"${BUILD_CXXFLAGS}\" \
        cros_host_extra_cppflags=\"${BUILD_CPPFLAGS}\" \
        cros_host_extra_ldflags=\"${BUILD_LDFLAGS}\" \
        target_sysroot=\"${STAGING_DIR_TARGET}\" \
        is_official_build=true  \
"
set -x
cd ${SRC_BUILD}

#Configure
echo "Configure CHROMIUM"
# Ninja complains if this is not correctly set.
echo LASTCHANGE='3ea904e3488e7af8b03e29fc71d9b9998ffc325b' > build/util/LASTCHANGE
echo LASTCHANGE='3ea904e3488e7af8b03e29fc71d9b9998ffc325b-refs/heads/master@{#497674}' > build/util/LASTCHANGE.blink
# Run GN
gn gen out/${CHROMIUM_BUILD_TYPE} --args="${EXTRA_OEGN}"


#Compile
echo "Compile CHROMIUM"
#Add infinity to fix issue 002-Rpath
for (( ; ; )) ;do
	# Build with ninja
	ninja -v -C ${SRC_BUILD}/out/Release -j 8 chrome chrome_sandbox mash:all	
	if [ $? -eq 0 ]; then
		break
	fi
	DO_BREAK=1
	echo "Try Fix 002-Rpath"
	for bin in brotli flatc character_data_generator protoc transport_security_state_generator proto_zero_plugin;do
		if [ -e ${SRC_BUILD}/out/Release/host/${bin} ]; then
			if chrpath -l ${SRC_BUILD}/out/Release/host/${bin}| grep -q ${OECORE_NATIVE_SYSROOT} ; then
				chrpath -r '/usr/lib:/lib' ${SRC_BUILD}/out/Release/host/${bin}
				DO_BREAK=0
			fi
		fi
	done
	if [ $DO_BREAK == 1 ];then
		echo "Something wrong append"
		exit 1;
	fi
done

echo "Install files"
#Install

if [ -f "${SRC_PKG}/google-chrome" ]; then
	install -Dm 0755 ${SRC_PKG}/google-chrome ${INST_PKG}/usr/bin/google-chrome
fi
if [ -f "${SRC_PKG}/cef-simple" ]; then
	install -Dm 0755 ${SRC_PKG}/cef-simple ${INST_PKG}/usr/bin/cef-simple
fi
if [ -f "${SRC_BUILD}/out/Release/chrome_sandbox" ]; then
	install -Dm 4755 ${SRC_BUILD}/out/Release/chrome_sandbox ${INST_PKG}/usr/sbin/chrome-devel-sandbox
fi
if [ -f "${SRC_BUILD}/out/Release/cefsimple" ]; then
	install -Dm 0755 ${SRC_BUILD}/out/Release/cefsimple ${INST_PKG}/usr/bin/chromium/cefsimple
fi
if [ -f "${SRC_BUILD}/out/Release/lib/libcef.so" ]; then
	install -Dm 0755 ${SRC_BUILD}/out/Release/lib/libcef.so ${INST_PKG}/usr/lib/chromium/libcef.so
fi
if [ -f "${SRC_BUILD}/out/Release/chrome" ]; then
	install -Dm 0755 ${SRC_BUILD}/out/Release/chrome ${INST_PKG}/usr/bin/chromium/chrome
fi
if [ -f "${SRC_BUILD}/out/Release/content_shell" ]; then
	install -Dm 4755 ${SRC_BUILD}/out/Release/content_shell ${INST_PKG}/usr/bin/chromium/content_shell
fi
if [ -f "${SRC_BUILD}/out/Release/icudtl.dat" ]; then
	install -Dm 0644 ${SRC_BUILD}/out/Release/icudtl.dat ${INST_PKG}/usr/bin/chromium/icudtl.dat
fi
if [ -f "${SRC_PKG}/google-chrome.desktop" ]; then
	install -Dm 0644 ${SRC_PKG}/google-chrome.desktop ${INST_PKG}/usr/share/applications/google-chrome.desktop
fi
if [ -f "${SRC_BUILD}/out/Release/product_logo_48.png" ]; then
	install -Dm 0644 ${SRC_BUILD}/out/Release/product_logo_48.png ${INST_PKG}/usr/bin/chromium/product_logo_48.png
fi

if [ -f "${SRC_BUILD}/out/Release/natives_blob.bin" ]; then
	install -Dm 0644 ${SRC_BUILD}/out/Release/natives_blob.bin ${INST_PKG}/usr/bin/chromium/natives_blob.bin
fi
if [ -f "${SRC_BUILD}/out/Release/snapshot_blob.bin" ]; then
	install -Dm 0644 ${SRC_BUILD}/out/Release/snapshot_blob.bin ${INST_PKG}/usr/bin/chromium/snapshot_blob.bin
fi

# Chromium plugins libs
for f in libpdf.so libosmesa.so libffmpegsumo.so; do
	if [ -f "${SRC_BUILD}/out/Release/$f" ]; then
		install -Dm 0644 ${SRC_BUILD}/out/Release/$f ${INST_PKG}/usr/lib/chromium/$f
	fi
done

# Chromium *.pak files and CEF pak files ( prefixed with cef_ )
for f in $(cd ${SRC_BUILD}/out/Release/ && find . -type f -name \*.pak); do
	install -Dm 0644 "${SRC_BUILD}/out/Release/${f}" "${INST_PKG}/usr/bin/chromium/${f}"
done

# Chromium resource files (for the inspector).
for f in $(cd ${SRC_BUILD}/out/Release/ && test -d resources && find resources -type f); do
	install -Dm 0644 "${SRC_BUILD}/out/Release/${f}" "${INST_PKG}/usr/bin/chromium/${f}"
done

# Chromium service manifests (for Mojo IPC).
for f in $(cd ${SRC_BUILD}/out/Release/ && find . -type f -name \*manifest.json); do
	install -Dm 0644 "${SRC_BUILD}/out/Release/${f}" "${INST_PKG}/usr/bin/chromium/${f}"
done

# Add extra command line arguments to google-chrome script by modifying
# the dummy "CHROME_EXTRA_ARGS" line
sed -i "s/^CHROME_EXTRA_ARGS=\"\"/CHROME_EXTRA_ARGS=\" --use-gl=egl --ignore-gpu-blacklist --enable-gpu-rasterization --enable-zero-copy --enable-native-gpu-memory-buffers\"/" ${INST_PKG}/usr/bin/google-chrome

# update ROOT_HOME with the root user's $HOME
sed -i "s#ROOT_HOME#/home/root#" ${INST_PKG}/usr/bin/google-chrome

# Always adding this libdir (not just with component builds), because the
# LD_LIBRARY_PATH line in the google-chromium script refers to it
install -d ${INST_PKG}/usr/lib/chromium/
if [ -n "" ]; then
	install -m 0755 ${SRC_BUILD}/out/Release/lib/*.so ${INST_PKG}/usr/lib/chromium/
fi


aarch64-agl-linux-strip --remove-section=.comment --remove-section=.note --strip-unneeded ${INST_PKG}/usr/bin/chromium/chrome
aarch64-agl-linux-strip --remove-section=.comment --remove-section=.note --strip-unneeded ${INST_PKG}/usr/lib/chromium/*.so

echo "that's all folks"




