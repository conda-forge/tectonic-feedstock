@echo on

@REM Here we ditch the -GL flag, which messes up our static libraries.
set "CFLAGS=-MD -DGRAPHITE2_STATIC"
set "CXXFLAGS=-MD -DGRAPHITE2_STATIC"
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX:\=/%/lib/pkgconfig;%LIBRARY_PREFIX:\=/%/share/pkgconfig"

# FIX UP LIBZ-SYS
cargo update

@REM Need to single-thread tests on Windows to avoid a filesystem locking issue.
@REM Also need to skip the Unicode filename test due to conda-build issue:
@REM  https://github.com/conda/conda-build/issues/4043
set RUST_TEST_THREADS=1
cargo test --release -- --skip unicode_file_name
if errorlevel 1 exit 1

cargo install --path . --bin tectonic --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\.crates.toml
del %LIBRARY_PREFIX%\.crates2.json
