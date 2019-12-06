#! /bin/bash

set -ex

# 2017 Dec 4: Work around SSL problem; see https://github.com/conda-forge/mosfit-feedstock/issues/23
unset REQUESTS_CA_BUNDLE
unset SSL_CERT_FILE

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"
fi

cargo build --release --verbose
cargo install --path . --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
