@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: CLIProxyAPI Plus Windows Installer
:: Downloads, installs, and upgrades CLIProxyAPI Plus
:: Plus version adds support for GitHub Copilot and Kiro
:: ============================================================

:: Configuration
set REPO_OWNER=router-for-me
set REPO_NAME=CLIProxyAPIPlus
set INSTALL_DIR=%USERPROFILE%\cliproxyapi
set API_URL=https://api.github.com/repos/%REPO_OWNER%/%REPO_NAME%/releases/latest
set SCRIPT_NAME=%~nx0

:: Parse command
set COMMAND=%~1
if "%COMMAND%"=="" set COMMAND=install

if /i "%COMMAND%"=="install" goto :cmd_install
if /i "%COMMAND%"=="upgrade" goto :cmd_install
if /i "%COMMAND%"=="status" goto :cmd_status
if /i "%COMMAND%"=="uninstall" goto :cmd_uninstall
if /i "%COMMAND%"=="help" goto :cmd_help
if /i "%COMMAND%"=="-h" goto :cmd_help
if /i "%COMMAND%"=="--help" goto :cmd_help

echo [ERROR] Unknown command: %COMMAND%
echo Use '%SCRIPT_NAME% help' for usage information.
exit /b 1

:: ============================================================
:: INSTALL / UPGRADE
:: ============================================================
:cmd_install

:: Check dependencies
where curl >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] curl is required but not found.
    echo         curl is included with Windows 10 1803+.
    echo         Please update Windows or install curl manually.
    pause
    exit /b 1
)
where tar >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] tar is required but not found.
    echo         tar is included with Windows 10 1803+.
    echo         Please update Windows or install tar manually.
    pause
    exit /b 1
)

:: Check current version
set IS_UPGRADE=0
set CURRENT_VERSION=none
if exist "%INSTALL_DIR%\version.txt" (
    set /p CURRENT_VERSION=<"%INSTALL_DIR%\version.txt"
    set IS_UPGRADE=1
    echo [INFO] Current CLIProxyAPI Plus version: !CURRENT_VERSION!
) else (
    echo [INFO] CLIProxyAPI Plus not installed, performing fresh installation
)

:: Detect architecture
set OS_ARCH=windows_amd64
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set OS_ARCH=windows_arm64
echo [STEP] Detected platform: %OS_ARCH%

:: Fetch latest release info
echo [INFO] Fetching latest release information...
set TEMP_JSON=%TEMP%\cliproxyapi_release_%RANDOM%.json
curl -s -o "%TEMP_JSON%" "%API_URL%"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to fetch release information from GitHub API
    del "%TEMP_JSON%" >nul 2>&1
    pause
    exit /b 1
)

:: Extract version from JSON using PowerShell
for /f "usebackq delims=" %%V in (`powershell -NoProfile -Command "(Get-Content '%TEMP_JSON%' -Raw | ConvertFrom-Json).tag_name -replace '^v',''"`) do (
    set VERSION=%%V
)
if "%VERSION%"=="" (
    echo [ERROR] Failed to extract version from release info
    del "%TEMP_JSON%" >nul 2>&1
    pause
    exit /b 1
)
echo [STEP] Latest version: %VERSION%

:: Check if already up to date
if "%IS_UPGRADE%"=="1" (
    if "%CURRENT_VERSION%"=="%VERSION%" (
        echo [SUCCESS] CLIProxyAPI Plus is already up to date (version %VERSION%^)
        del "%TEMP_JSON%" >nul 2>&1
        goto :eof
    )
)

:: Build expected filename and extract download URL
set EXPECTED_FILE=CLIProxyAPIPlus_%VERSION%_%OS_ARCH%.zip
echo [INFO] Looking for asset: %EXPECTED_FILE%

for /f "usebackq delims=" %%U in (`powershell -NoProfile -Command "$r = Get-Content '%TEMP_JSON%' -Raw | ConvertFrom-Json; ($r.assets | Where-Object { $_.name -eq '%EXPECTED_FILE%' }).browser_download_url"`) do (
    set DOWNLOAD_URL=%%U
)
del "%TEMP_JSON%" >nul 2>&1

if "%DOWNLOAD_URL%"=="" (
    echo [ERROR] Failed to find download URL for %EXPECTED_FILE%
    pause
    exit /b 1
)

:: Stop running processes before upgrade
if "%IS_UPGRADE%"=="1" (
    echo [INFO] Checking for running CLIProxyAPI processes...
    tasklist /FI "IMAGENAME eq cli-proxy-api-plus.exe" 2>nul | find /I "cli-proxy-api-plus.exe" >nul 2>&1
    if !errorLevel! equ 0 (
        echo [INFO] Stopping running CLIProxyAPI processes...
        taskkill /F /IM cli-proxy-api-plus.exe >nul 2>&1
        timeout /t 2 /nobreak >nul
        echo [SUCCESS] Processes stopped
    )
)

:: Backup config if upgrading
set BACKUP_FILE=
if "%IS_UPGRADE%"=="1" (
    if exist "%INSTALL_DIR%\config.yaml" (
        if not exist "%INSTALL_DIR%\config_backup" mkdir "%INSTALL_DIR%\config_backup"
        for /f "tokens=1-6 delims=/:. " %%a in ("%date% %time%") do (
            set TIMESTAMP=%%a%%b%%c_%%d%%e%%f
        )
        set BACKUP_FILE=%INSTALL_DIR%\config_backup\config_!TIMESTAMP!.yaml
        copy "%INSTALL_DIR%\config.yaml" "!BACKUP_FILE!" >nul
        echo [INFO] Configuration backed up to: !BACKUP_FILE!
    )
)

:: Create install directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
set VERSION_DIR=%INSTALL_DIR%\%VERSION%

:: Download
set TEMP_ZIP=%TEMP%\cliproxyapi_%RANDOM%.zip
echo [INFO] Downloading %EXPECTED_FILE%...
curl -L -o "%TEMP_ZIP%" "%DOWNLOAD_URL%"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to download file
    del "%TEMP_ZIP%" >nul 2>&1
    pause
    exit /b 1
)
echo [SUCCESS] Download completed

:: Extract
echo [INFO] Extracting archive to %VERSION_DIR%...
if not exist "%VERSION_DIR%" mkdir "%VERSION_DIR%"
tar -xf "%TEMP_ZIP%" -C "%VERSION_DIR%"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to extract archive
    del "%TEMP_ZIP%" >nul 2>&1
    pause
    exit /b 1
)
del "%TEMP_ZIP%" >nul 2>&1
echo [SUCCESS] Extraction completed

:: Copy executable to main directory
echo [INFO] Setting up installation...
if exist "%VERSION_DIR%\cli-proxy-api-plus.exe" (
    copy /Y "%VERSION_DIR%\cli-proxy-api-plus.exe" "%INSTALL_DIR%\cli-proxy-api-plus.exe" >nul
    echo [SUCCESS] Copied executable to %INSTALL_DIR%\cli-proxy-api-plus.exe
) else (
    echo [ERROR] cli-proxy-api-plus.exe not found in %VERSION_DIR%
    pause
    exit /b 1
)

:: Copy service management scripts and nssm
set INSTALLER_DIR=%~dp0
set INSTALLER_DIR=%INSTALLER_DIR:~0,-1%

if exist "%INSTALLER_DIR%\install_service.bat" (
    copy /Y "%INSTALLER_DIR%\install_service.bat" "%INSTALL_DIR%\install_service.bat" >nul
    echo [SUCCESS] Copied install_service.bat
)
if exist "%INSTALLER_DIR%\uninstall_service.bat" (
    copy /Y "%INSTALLER_DIR%\uninstall_service.bat" "%INSTALL_DIR%\uninstall_service.bat" >nul
    echo [SUCCESS] Copied uninstall_service.bat
)
if exist "%INSTALLER_DIR%\nssm-2.24" (
    xcopy /E /I /Y /Q "%INSTALLER_DIR%\nssm-2.24" "%INSTALL_DIR%\nssm-2.24" >nul
    echo [SUCCESS] Copied nssm-2.24
)

:: Setup configuration
if defined BACKUP_FILE (
    if exist "!BACKUP_FILE!" (
        copy /Y "!BACKUP_FILE!" "%INSTALL_DIR%\config.yaml" >nul
        echo [SUCCESS] Restored configuration from backup
        goto :config_done
    )
)
if exist "%INSTALL_DIR%\config.yaml" (
    echo [SUCCESS] Preserved existing user configuration (config.yaml^)
    goto :config_done
)
if exist "%VERSION_DIR%\config.example.yaml" (
    copy /Y "%VERSION_DIR%\config.example.yaml" "%INSTALL_DIR%\config.yaml" >nul

    :: Generate API keys using PowerShell for proper randomness
    for /f "usebackq delims=" %%K in (`powershell -NoProfile -Command "$c='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';$r=[System.Random]::new();'sk-'+-join(1..45|%%{$c[$r.Next($c.Length)]})"`) do set KEY1=%%K
    for /f "usebackq delims=" %%K in (`powershell -NoProfile -Command "$c='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';$r=[System.Random]::new();'sk-'+-join(1..45|%%{$c[$r.Next($c.Length)]})"`) do set KEY2=%%K

    powershell -NoProfile -Command "(Get-Content '%INSTALL_DIR%\config.yaml') -replace '\"your-api-key-1\"','\"!KEY1!\"' -replace '\"your-api-key-2\"','\"!KEY2!\"' | Set-Content '%INSTALL_DIR%\config.yaml'"

    echo [SUCCESS] Created config.yaml from example with generated API keys
    echo [INFO] Generated API keys: !KEY1!, !KEY2!
    echo [INFO] You can find your API keys in: %INSTALL_DIR%\config.yaml
) else (
    echo [WARNING] config.example.yaml not found, you may need to create config.yaml manually
)
:config_done

:: Write version file
echo %VERSION%> "%INSTALL_DIR%\version.txt"
echo [SUCCESS] Version %VERSION% written to version.txt

:: Clean up old versions (keep latest 2)
echo [INFO] Cleaning up old versions...
set KEEP_COUNT=0
for /f "delims=" %%D in ('dir /AD /B /O-N "%INSTALL_DIR%" 2^>nul ^| findstr /R "[0-9]*\.[0-9]*\.[0-9]*"') do (
    set /a KEEP_COUNT+=1
    if !KEEP_COUNT! gtr 2 (
        rmdir /S /Q "%INSTALL_DIR%\%%D" 2>nul
        echo [INFO] Removed old version: %%D
    )
)

:: Success message
echo.
if "%IS_UPGRADE%"=="1" (
    echo ============================================================
    echo  [SUCCESS] CLIProxyAPI Plus upgraded from %CURRENT_VERSION% to %VERSION%!
    echo ============================================================
) else (
    echo ============================================================
    echo  [SUCCESS] CLIProxyAPI Plus %VERSION% installed successfully!
    echo ============================================================
)
echo.
echo  Install Directory: %INSTALL_DIR%
echo.

:: Show authentication info
echo  Authentication Commands:
echo  -------------------------------------------------------
echo  Gemini:           cli-proxy-api-plus.exe --login
echo  OpenAI:           cli-proxy-api-plus.exe --codex-login
echo  Claude:           cli-proxy-api-plus.exe --claude-login
echo  Qwen:             cli-proxy-api-plus.exe --qwen-login
echo  iFlow:            cli-proxy-api-plus.exe --iflow-login
echo  GitHub Copilot:   cli-proxy-api-plus.exe --copilot-login
echo  Kiro (Web OAuth): http://localhost:8317/v0/oauth/kiro
echo.
echo  Add --no-browser to print URL instead of opening browser.
echo.

:: Show next steps
echo  Quick Start:
echo  -------------------------------------------------------
echo  1. cd %INSTALL_DIR%
echo  2. Edit config.yaml to configure API keys (if needed)
echo  3. Run authentication commands above for your providers
echo  4. Start directly: cli-proxy-api-plus.exe
echo  5. Or install as Windows service:
echo     Run install_service.bat as Administrator
echo.
echo  Documentation: https://github.com/router-for-me/CLIProxyAPIPlus
echo.
pause
goto :eof

:: ============================================================
:: STATUS
:: ============================================================
:cmd_status

echo.
echo  CLIProxyAPI Plus Installation Status
echo  ============================================================

if not exist "%INSTALL_DIR%\version.txt" (
    echo  Status: Not installed
    echo.
    pause
    goto :eof
)

set /p CURRENT_VERSION=<"%INSTALL_DIR%\version.txt"
echo  Install Directory: %INSTALL_DIR%
echo  Current Version:   %CURRENT_VERSION%

if exist "%INSTALL_DIR%\cli-proxy-api-plus.exe" (
    echo  Executable:        Present
) else (
    echo  Executable:        MISSING
)

if exist "%INSTALL_DIR%\config.yaml" (
    echo  Configuration:     Present
) else (
    echo  Configuration:     MISSING
)

if exist "%INSTALL_DIR%\install_service.bat" (
    echo  Service Installer: Present
) else (
    echo  Service Installer: Not available
)

if exist "%INSTALL_DIR%\nssm-2.24\win64\nssm.exe" (
    echo  NSSM:              Present
) else (
    echo  NSSM:              Not available
)

:: Check if Windows service is installed
sc query CLIProxyAPI >nul 2>&1
if %errorLevel% equ 0 (
    echo  Windows Service:   Installed
    for /f "tokens=3 delims=: " %%S in ('sc query CLIProxyAPI ^| findstr "STATE"') do (
        echo  Service State:     %%S
    )
) else (
    echo  Windows Service:   Not installed
)

:: Show installed versions
echo.
echo  Installed Versions:
for /f "delims=" %%D in ('dir /AD /B /O-N "%INSTALL_DIR%" 2^>nul ^| findstr /R "[0-9]*\.[0-9]*\.[0-9]*"') do (
    echo    %%D
)
echo.
pause
goto :eof

:: ============================================================
:: UNINSTALL
:: ============================================================
:cmd_uninstall

if not exist "%INSTALL_DIR%" (
    echo [WARNING] CLIProxyAPI Plus installation directory not found: %INSTALL_DIR%
    pause
    goto :eof
)

echo.
echo  CLIProxyAPI Plus installation found at: %INSTALL_DIR%
echo.

:: Check if service is installed and remove it first
sc query CLIProxyAPI >nul 2>&1
if %errorLevel% equ 0 (
    echo [WARNING] Windows service 'CLIProxyAPI' is installed.
    echo          Please run uninstall_service.bat first to remove the service,
    echo          or the service will be forcefully stopped.
    echo.
    set /p SVC_CONFIRM="Continue anyway? (Y/N): "
    if /i "!SVC_CONFIRM!" neq "Y" (
        echo.
        echo Uninstallation cancelled.
        pause
        goto :eof
    )
    echo [INFO] Stopping service...
    net stop CLIProxyAPI >nul 2>&1
    if exist "%INSTALL_DIR%\nssm-2.24\win64\nssm.exe" (
        "%INSTALL_DIR%\nssm-2.24\win64\nssm.exe" remove CLIProxyAPI confirm >nul 2>&1
    ) else (
        sc delete CLIProxyAPI >nul 2>&1
    )
    timeout /t 2 /nobreak >nul
)

set /p CONFIRM="Are you sure you want to remove CLIProxyAPI Plus? (Y/N): "
if /i "%CONFIRM%" neq "Y" (
    echo.
    echo Uninstallation cancelled.
    pause
    goto :eof
)

:: Stop any running processes
taskkill /F /IM cli-proxy-api-plus.exe >nul 2>&1

echo [INFO] Removing CLIProxyAPI Plus installation...
rmdir /S /Q "%INSTALL_DIR%"
echo [SUCCESS] CLIProxyAPI Plus has been uninstalled successfully.
echo.
pause
goto :eof

:: ============================================================
:: HELP
:: ============================================================
:cmd_help

echo.
echo  CLIProxyAPI Plus Windows Installer
echo  ============================================================
echo.
echo  Usage: %SCRIPT_NAME% [COMMAND]
echo.
echo  Commands:
echo    install, upgrade   Install or upgrade CLIProxyAPI Plus (default)
echo    status             Show current installation status
echo    uninstall          Remove CLIProxyAPI Plus completely
echo    help, -h, --help   Show this help message
echo.
echo  Description:
echo    This script downloads, installs, and upgrades CLIProxyAPI Plus
echo    on Windows. It automatically detects your architecture and
echo    downloads the correct release from GitHub.
echo.
echo    During upgrades, your config.yaml is preserved automatically.
echo.
echo    CLIProxyAPI Plus adds support for:
echo    - GitHub Copilot (OAuth login)
echo    - Kiro/AWS CodeWhisperer (OAuth web authentication)
echo    - Enhanced rate limiting and monitoring features
echo.
echo  Installation Directory: %USERPROFILE%\cliproxyapi\
echo.
echo  Service Management:
echo    After installation, use install_service.bat and
echo    uninstall_service.bat (run as Administrator) to manage
echo    the Windows service via NSSM.
echo.
echo  Examples:
echo    %SCRIPT_NAME%              Install or upgrade
echo    %SCRIPT_NAME% status       Show current status
echo    %SCRIPT_NAME% uninstall    Remove completely
echo.
echo  More Info: https://github.com/router-for-me/CLIProxyAPIPlus
echo.
pause
goto :eof
