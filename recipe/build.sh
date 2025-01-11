#!/usr/bin/env bash

set -ex

export PKG_CONFIG_ALLOW_CROSS=1

# https://github.com/rust-lang/cargo/issues/10583#issuecomment-1129997984
export CARGO_NET_GIT_FETCH_WITH_CLI=true

if [ $(uname) = Darwin ]; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++17"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"

    if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
        DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib RUSTDOCFLAGS="-C linker=$CC" cargo test --release --features external-harfbuzz
    fi
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"

    if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
        LD_LIBRARY_PATH=$PREFIX/lib RUSTDOCFLAGS="-C linker=$CC" cargo test --release --features external-harfbuzz
    fi
fi

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --no-track --locked --path . --bin tectonic --root $PREFIX --features external-harfbuzz
rm -f $PREFIX/.crates.toml
rm -f $PREFIX/.crates2.json
