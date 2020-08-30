#! /bin/bash

set -ex

# 2017 Dec 4: Work around SSL problem; see https://github.com/conda-forge/mosfit-feedstock/issues/23
unset REQUESTS_CA_BUNDLE
unset SSL_CERT_FILE

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"

    # Note: the hope is that if we test in --release mode, we can avoid
    # rebuilding everything for the `cargo install` command, but in practice
    # this seems not to work. From local investigation it *seems* that the
    # environment variables are not responsible, but I'm not sure exactly how
    # cargo is deciding if/when rebuilds are needed.
    DYLD_LIBRARY_PATH=$PREFIX/lib RUSTDOCFLAGS="-C linker=$CC" cargo test --release
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"

    LD_LIBRARY_PATH=$PREFIX/lib RUSTDOCFLAGS="-C linker=$CC" cargo test --release
fi


cargo install --path . --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
rm -f $PREFIX/.crates2.json
