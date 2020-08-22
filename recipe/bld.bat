@echo on

@REM Here we ditch the -GL flag, which messes up our static libraries.
set "CFLAGS=-MD -DGRAPHITE2_STATIC"
set "CXXFLAGS=-MD -DGRAPHITE2_STATIC"

set "PKG_CONFIG_PATH=%LIBRARY_PREFIX:\=/%/lib/pkgconfig;%LIBRARY_PREFIX:\=/%/share/pkgconfig"

@REM Sigh, import library names are all over the place
copy %LIBRARY_PREFIX%\lib\libxml2_a.lib %LIBRARY_PREFIX%\lib\xml2.lib

cargo build --release --verbose
if errorlevel 1 exit 1

cargo install --path . --bin tectonic --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\.crates.toml
del %LIBRARY_PREFIX%\lib\xml2.lib
