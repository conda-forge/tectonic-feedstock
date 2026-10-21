@echo on

@REM Here we ditch the -GL flag, which messes up our static libraries.
set "CFLAGS=-MD -DGRAPHITE2_STATIC"
set "CXXFLAGS=-MD -DGRAPHITE2_STATIC -std:c++17"
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX:\=/%/lib/pkgconfig;%LIBRARY_PREFIX:\=/%/share/pkgconfig"

@rem https://github.com/conda-forge/conda-forge.github.io/issues/2967
cargo update webpki-root-certs rustls-webpki

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

@REM Need to single-thread tests on Windows to avoid a filesystem locking issue.
set RUST_TEST_THREADS=1
cargo test --release --features external-harfbuzz
if errorlevel 1 exit 1

cargo install --no-track --locked --path . --bin tectonic --root %LIBRARY_PREFIX% --features external-harfbuzz
if errorlevel 1 exit 1
