#! /bin/bash

set -ex

# 2017 Dec 4: Work around SSL problem; see https://github.com/conda-forge/mosfit-feedstock/issues/23
unset REQUESTS_CA_BUNDLE
unset SSL_CERT_FILE

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"

    # Well, I have no idea what's going on here. But if we don't run these
    # programs like this, the build fails with errors about not being able to
    # find "cc" and "ar". ???? -- PKGW 2018 Sep 16.
    set +e
    cc --help
    ar --help
    set -e
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"
fi

cargo build --release --verbose
cargo install --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
