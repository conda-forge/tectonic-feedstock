#! /bin/bash

set -ex

export PKG_CONFIG_ALLOW_CROSS=1

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"

    # Note: the hope is that if we test in --release mode, we can avoid
    # rebuilding everything for the `cargo install` command, but in practice
    # this seems not to work. From local investigation it *seems* that the
    # environment variables are not responsible, but I'm not sure exactly how
    # cargo is deciding if/when rebuilds are needed.

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


cargo install --path . --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
rm -f $PREFIX/.crates2.json
