@echo on

@REM Here we ditch the -GL flag, which messes up our static libraries.
set "CFLAGS=-MD -DGRAPHITE2_STATIC"
set "CXXFLAGS=-MD -DGRAPHITE2_STATIC -std:c++17"
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX:\=/%/lib/pkgconfig;%LIBRARY_PREFIX:\=/%/share/pkgconfig"

@REM FIX UP LIBZ-SYS
cargo update

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

@REM Need to single-thread tests on Windows to avoid a filesystem locking issue.
@REM Also need to skip the Unicode filename test due to conda-build issue:
@REM  https://github.com/conda/conda-build/issues/4043
set RUST_TEST_THREADS=1
cargo test --release --features external-harfbuzz -- --skip unicode_file_name
if errorlevel 1 exit 1

cargo install --path . --bin tectonic --root %LIBRARY_PREFIX% --features external-harfbuzz
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\.crates.toml
del %LIBRARY_PREFIX%\.crates2.json
