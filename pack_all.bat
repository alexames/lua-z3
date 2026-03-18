@echo off
setlocal enabledelayedexpansion

REM Create binary .rock files for all Lua versions from the dist/ directory.
REM
REM Prerequisites:
REM   - Run build_all.bat first to populate dist/
REM
REM Output:
REM   rocks/lua-z3-VERSION-LV.win32-x86_64.rock for each Lua version LV
REM
REM Usage:
REM   pack_all.bat                 - Pack all versions
REM   pack_all.bat 54 55           - Pack only specified versions

set "SOURCE_DIR=%~dp0"
set "DIST_DIR=%SOURCE_DIR%dist"
set "ROCKS_DIR=%SOURCE_DIR%rocks"
set "ROCK_TEMPLATE_DIR=%SOURCE_DIR%rock"
set "ROCK_VERSION=0.1.0"
set "ARCH=win32-x86_64"

REM If specific versions are given as arguments, use those. Otherwise pack all.
set "VERSIONS="
if "%~1"=="" (
    set "VERSIONS=51 52 53 54 55"
) else (
    :parse_args
    if "%~1"=="" goto :done_args
    set "VERSIONS=!VERSIONS! %~1"
    shift
    goto :parse_args
)
:done_args

if not exist "%ROCKS_DIR%" mkdir "%ROCKS_DIR%"

for %%V in (%VERSIONS%) do (
    echo.
    echo ================================================================
    echo Packing binary rock for Lua %%V
    echo ================================================================
    echo.

    REM Derive dotted Lua version (e.g. "54" -> "5.4")
    set "LV=%%V"
    set "LUA_DOT=!LV:~0,1!.!LV:~1,1!"

    REM Derive the next minor version for upper bound (e.g. "5.4" -> "5.5")
    set /a "MINOR=!LV:~1,1! + 1"
    set "LUA_NEXT=!LV:~0,1!.!MINOR!"

    set "ROCK_FULLVER=%ROCK_VERSION%-%%V"
    set "ROCK_NAME=lua-z3-!ROCK_FULLVER!"
    set "ROCK_FILE=!ROCK_NAME!.%ARCH%.rock"
    set "STAGING=%ROCKS_DIR%\staging\!ROCK_NAME!"

    REM Check that dist files exist
    if not exist "%DIST_DIR%\lua%%V\z3.dll" (
        echo ERROR: dist\lua%%V\z3.dll not found. Run build_all.bat first.
        exit /b 1
    )
    if not exist "%DIST_DIR%\lua%%V\libz3.dll" (
        echo ERROR: dist\lua%%V\libz3.dll not found. Run build_all.bat first.
        exit /b 1
    )

    REM Clean and create staging directory
    if exist "!STAGING!" rmdir /s /q "!STAGING!"
    mkdir "!STAGING!\lib"
    mkdir "!STAGING!\lua"

    REM Copy module files
    copy /Y "%DIST_DIR%\lua%%V\z3.dll" "!STAGING!\lib\z3_native.dll" >nul
    copy /Y "%DIST_DIR%\lua%%V\libz3.dll" "!STAGING!\lib\libz3.dll" >nul
    copy /Y "%ROCK_TEMPLATE_DIR%\z3.lua" "!STAGING!\lua\z3.lua" >nul

    REM Generate rockspec
    (
        echo package = "lua-z3"
        echo version = "!ROCK_FULLVER!"
        echo.
        echo source = {
        echo    url = "git+https://github.com/alexames/lua-z3.git",
        echo    tag = "v%ROCK_VERSION%"
        echo }
        echo.
        echo description = {
        echo    summary = "Lua bindings for the Z3 theorem prover",
        echo    detailed = [[
        echo       lua-z3 provides Lua bindings for the Z3 theorem prover,
        echo       allowing you to use Z3's powerful SMT solving capabilities
        echo       directly from Lua code.
        echo    ]],
        echo    homepage = "https://github.com/alexames/lua-z3",
        echo    license = "MIT"
        echo }
        echo.
        echo dependencies = {
        echo    "lua ^>= !LUA_DOT!, ^< !LUA_NEXT!"
        echo }
        echo.
        echo build = {
        echo    type = "builtin",
        echo    modules = {}
        echo }
    ) > "!STAGING!\!ROCK_NAME!.rockspec"

    REM Generate rock_manifest with MD5 hashes
    for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm MD5 '!STAGING!\lib\z3_native.dll').Hash.ToLower()"') do set "HASH_NATIVE=%%H"
    for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm MD5 '!STAGING!\lib\libz3.dll').Hash.ToLower()"') do set "HASH_LIBZ3=%%H"
    for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm MD5 '!STAGING!\lua\z3.lua').Hash.ToLower()"') do set "HASH_LUA=%%H"
    for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm MD5 '!STAGING!\!ROCK_NAME!.rockspec').Hash.ToLower()"') do set "HASH_SPEC=%%H"

    (
        echo rock_manifest = {
        echo    lib = {
        echo       ["z3_native.dll"] = "!HASH_NATIVE!",
        echo       ["libz3.dll"] = "!HASH_LIBZ3!"
        echo    },
        echo    lua = {
        echo       ["z3.lua"] = "!HASH_LUA!"
        echo    },
        echo    ["!ROCK_NAME!.rockspec"] = "!HASH_SPEC!"
        echo }
    ) > "!STAGING!\rock_manifest"

    REM Create the .rock file (zip archive)
    if exist "%ROCKS_DIR%\!ROCK_FILE!" del "%ROCKS_DIR%\!ROCK_FILE!"
    powershell -NoProfile -Command "Compress-Archive -Path '!STAGING!\*' -DestinationPath '%ROCKS_DIR%\!ROCK_FILE!.zip' -Force; Rename-Item '%ROCKS_DIR%\!ROCK_FILE!.zip' '!ROCK_FILE!'"

    REM Also copy the rockspec to the rocks directory for deployment
    copy /Y "!STAGING!\!ROCK_NAME!.rockspec" "%ROCKS_DIR%\!ROCK_NAME!.rockspec" >nul

    REM Clean up staging
    rmdir /s /q "!STAGING!"

    if exist "%ROCKS_DIR%\!ROCK_FILE!" (
        echo Successfully created rocks\!ROCK_FILE!
    ) else (
        echo ERROR: Failed to create !ROCK_FILE!
        exit /b 1
    )
)

REM Clean up empty staging directory
if exist "%ROCKS_DIR%\staging" rmdir /s /q "%ROCKS_DIR%\staging"

echo.
echo ================================================================
echo All rocks packed. Files are in the rocks\ directory:
echo ================================================================
for %%V in (%VERSIONS%) do (
    set "ROCK_FULLVER=%ROCK_VERSION%-%%V"
    if exist "%ROCKS_DIR%\lua-z3-!ROCK_FULLVER!.%ARCH%.rock" (
        echo   lua-z3-!ROCK_FULLVER!.%ARCH%.rock
    )
)
echo.
