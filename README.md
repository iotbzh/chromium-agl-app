# Chromium-agl-app

## Build AGL SDK

- Follow : https://github.com/Igalia/meta-browser/wiki
- Add meta: meta-sdk-chrom to your conf/bblayers.conf

```bash
BBLAYERS =+ "\
  ${METADIR}/sdk_chromium/meta-sdk-chrom \
"
```

- Build AGL SDK

```
bitbake agl-demo-platform-crosssdk
```

- Install SDK

```bash
install_sdk tmp/deploy/sdk/poky-agl-glibc-x86_64-agl-demo-platform-crosssdk-aarch64-toolchain-4.0.1.sh
```

## Build chromium with AGL SDK

- prepare SDK env

```bash
source /xdt/sdk/environment-setup-aarch64-agl-linux
```

- download source file and prepare build:

```bash
./getsource.sh
```

- build chromium

```bash
./build_chromium.sh
```

## Issues

### 001 Use ld-gold

ld-gold is mandatory to build chromium

Fix: docker image worker-generic use  ld-gold as default ld

### 002 Rpath

chromium build 6 host tools: src/out/Release/host/

- brotli
- character_data_generator
- flatc
- protoc
- proto_zero_plugin
- transport_security_state_generator

The rpath of this files use /xdt/sdk/sysroots/x86_64-aglsdk-linux/ path.

But we need to use host libc (Unknown reason for now)

```bash
chrpath -l ${SRC_BUILD}/out/Release/host/${bin}
```

Fix: use chrpath to change file rpath

```bash
chrpath -r '/usr/lib:/lib' ${SRC_BUILD}/out/Release/host/${bin}
```

## Package chromium into wgt file

TODO
