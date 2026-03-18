@echo off
setlocal enabledelayedexpansion

REM Deploy binary rocks and rockspecs to the luarocks repository.
REM
REM Prerequisites:
REM   - Run build_all.bat then pack_all.bat first
REM   - luarocks-admin must be on PATH
REM
REM Usage:
REM   deploy.bat                                           - Deploy to default repo
REM   deploy.bat C:\path\to\luarocks-repository            - Deploy to custom repo

set "SOURCE_DIR=%~dp0"
set "ROCKS_DIR=%SOURCE_DIR%rocks"

REM Default repository location
set "REPO_DIR=C:\Users\Alexa\Programming\luarocks-repository"
if not "%~1"=="" set "REPO_DIR=%~1"

if not exist "%ROCKS_DIR%" (
    echo ERROR: rocks\ directory not found. Run pack_all.bat first.
    exit /b 1
)

if not exist "%REPO_DIR%" (
    echo ERROR: Repository directory not found: %REPO_DIR%
    exit /b 1
)

echo.
echo Deploying to: %REPO_DIR%
echo.

REM Copy .rock files and .rockspec files
set "COUNT=0"
for %%F in ("%ROCKS_DIR%\lua-z3-*.rock") do (
    echo   Copying %%~nxF
    copy /Y "%%F" "%REPO_DIR%\%%~nxF" >nul
    set /a "COUNT+=1"
)
for %%F in ("%ROCKS_DIR%\lua-z3-*.rockspec") do (
    echo   Copying %%~nxF
    copy /Y "%%F" "%REPO_DIR%\%%~nxF" >nul
)

if %COUNT%==0 (
    echo ERROR: No .rock files found in rocks\. Run pack_all.bat first.
    exit /b 1
)

echo.
echo Regenerating manifests...
pushd "%REPO_DIR%"
luarocks-admin make-manifest .
popd

echo.
echo ================================================================
echo Deployment complete. %COUNT% binary rock(s) deployed.
echo.
echo Next steps:
echo   cd %REPO_DIR%
echo   git add -A
echo   git commit -m "Add lua-z3 binary rocks"
echo   git push
echo ================================================================
echo.
