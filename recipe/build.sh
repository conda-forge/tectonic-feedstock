#! /bin/bash

set -ex

export PKG_CONFIG_ALLOW_CROSS=1

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"

    if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
        DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib RUSTDOCFLAGS="-C linker=$CC" cargo test --release
    fi
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"

    if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
        LD_LIBRARY_PATH=$PREFIX/lib RUSTDOCFLAGS="-C linker=$CC" cargo test --release
    fi
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --no-track --path . --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
rm -f $PREFIX/.crates2.json
