#RDEPENDS_${PN} += " nativesdk-gn "

TOOLCHAIN_HOST_TASK += " nativesdk-gn nativesdk-ninja nativesdk-gperf nativesdk-zlib nativesdk-xz nativesdk-nspr-dev"

TOOLCHAIN_TARGET_TASK += " pciutils-dev pulseaudio-dev cairo-dev nss-dev cups-dev gconf-dev libexif-dev pango-dev libdrm-dev libssp-dev ffmpeg-dev"
#libav -> ffmpeg-dev

