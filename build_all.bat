@echo off
setlocal enabledelayedexpansion

REM Build lua-z3 for all supported Lua versions (5.1 through 5.5).
REM Each version gets its own build directory and output DLL.
REM
REM Usage:
REM   build_all.bat                 - Build all versions
REM   build_all.bat 54 55           - Build only specified versions
REM
REM Prerequisites:
REM   - CMake 3.21+
REM   - Visual Studio 2022
REM   - vcpkg (bootstrapped automatically by CMake)

set "SOURCE_DIR=%~dp0"
set "CMAKE=cmake"

REM If specific versions are given as arguments, use those. Otherwise build all.
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

for %%V in (%VERSIONS%) do (
    echo.
    echo ================================================================
    echo Building lua-z3 for Lua %%V
    echo ================================================================
    echo.

    set "BUILD_DIR=%SOURCE_DIR%build\lua%%V"

    REM Configure
    "%CMAKE%" -S "%SOURCE_DIR%" -B "!BUILD_DIR!" ^
        -DLUA_VERSION=%%V ^
        || (
            echo ERROR: CMake configure failed for Lua %%V
            exit /b 1
        )

    REM Build Release
    "%CMAKE%" --build "!BUILD_DIR!" --config Release || (
        echo ERROR: Build failed for Lua %%V
        exit /b 1
    )

    REM Copy the output DLL to a predictable location
    if not exist "%SOURCE_DIR%dist\lua%%V" mkdir "%SOURCE_DIR%dist\lua%%V"
    copy /Y "!BUILD_DIR!\Source\z3\Release\z3.dll" "%SOURCE_DIR%dist\lua%%V\z3.dll" >nul

    echo.
    echo Successfully built dist\lua%%V\z3.dll
)

echo.
echo ================================================================
echo All builds complete. DLLs are in the dist\ directory:
echo ================================================================
for %%V in (%VERSIONS%) do (
    if exist "%SOURCE_DIR%dist\lua%%V\z3.dll" (
        echo   dist\lua%%V\z3.dll
    )
)
echo.
