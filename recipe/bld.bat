@echo on

@REM Here we ditch the -GL flag, which messes up our static libraries.
set "CFLAGS=-MD -DGRAPHITE2_STATIC"
set "CXXFLAGS=-MD -DGRAPHITE2_STATIC"
set "PKG_CONFIG_PATH=%LIBRARY_PREFIX:\=/%/lib/pkgconfig;%LIBRARY_PREFIX:\=/%/share/pkgconfig"

@REM Need to single-thread tests on Windows to avoid a filesystem locking issue.
set RUST_TEST_THREADS=1
cargo test --release
if errorlevel 1 exit 1

cargo install --path . --bin tectonic --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\.crates.toml
del %LIBRARY_PREFIX%\.crates2.json
