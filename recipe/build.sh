#! /bin/bash

set -ex

# 2017 Dec 4: Work around SSL problem; see https://github.com/conda-forge/mosfit-feedstock/issues/23
unset REQUESTS_CA_BUNDLE
unset SSL_CERT_FILE

if [ $(uname) = Darwin ] ; then
    export CXXFLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
    export RUSTFLAGS="-C link-args=-Wl,-rpath,$PREFIX/lib"

    # HACK: Well, I have no idea what's going on here. But if we don't run
    # these programs like this, the build fails with errors about not being
    # able to find the various developer tools:
    #
    # /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -sdk / -find clang 2> /dev/null
    # cc: error: unable to find utility "clang", not a developer tool or in PATH
    #
    # Certain dependent libraries compile C code in ways that don't respect
    # $CC, so to cover all the bases for all toolchains we need to invoke `cc`
    # explicitly.
    set +e
    cc --help
    $CC --help
    $CXX --help
    ar --help
    set -e

    # HACK: work around https://github.com/rust-lang/rust/issues/51838 .
    # On Travis we currently use an old version of macOS that crashes
    # when rustc tries to resize the stack of its main thread. By setting
    # hard stack size ulimit to be smaller than Rust wants, we trigger code
    # in rustc that launches the compiler in a thread, avoiding the crash.
    ulimit -s 1024

    # HACK: work around
    # https://github.com/rust-lang/cargo/issues/2888#issuecomment-431049264 .
    # To configure the build Cargo compiles and executes the Tectonic "build
    # script", which in turn invokes pkg-config. But cargo runs the build
    # script with DYLD_LIBRARY_PATH set, which causes pkg-config to fail: the
    # environment variable causes the linker to try to link the system's
    # libcups with conda-forge's libiconv, which is incompatible with the
    # system version. As it happens, conda-forge's pkg-config is already a
    # wrapper script, so we hack it to unset the variable. Fun times.
    pc=$(which pkg-config)
    cp $pc $pc.orig
    cat <<EOF >$pc
#!/usr/bin/env bash
unset DYLD_LIBRARY_PATH
EOF
    cat $pc.orig >>$pc
    chmod +x $pc
else
    export CFLAGS="-std=gnu99 $CFLAGS"
    export RUSTFLAGS="-C link-args=-Wl,-rpath-link,$PREFIX/lib"
fi

cargo build --release --verbose
cargo install --bin tectonic --root $PREFIX
rm -f $PREFIX/.crates.toml
