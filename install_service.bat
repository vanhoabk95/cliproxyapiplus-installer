@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: CLI Proxy API - Windows Service Installer
:: ============================================================

:: Service configuration
set SERVICE_NAME=CLIProxyAPI
set SERVICE_DISPLAY_NAME=CLI Proxy API
set SERVICE_DESCRIPTION=A proxy server providing OpenAI/Gemini/Claude compatible API interfaces

:: Get the directory where this script is located
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

:: Set paths
set NSSM_PATH=%SCRIPT_DIR%\nssm-2.24\win64\nssm.exe
set APP_PATH=%SCRIPT_DIR%\cli-proxy-api-plus.exe
set APP_DIR=%SCRIPT_DIR%

:: Check if NSSM exists
if not exist "%NSSM_PATH%" (
    echo ============================================================
    echo  ERROR: NSSM not found!
    echo ============================================================
    echo.
    echo Expected path: %NSSM_PATH%
    echo.
    echo Please ensure nssm-2.24 folder is in the same directory as this script.
    echo.
    pause
    exit /b 1
)

:: Check if application exists
if not exist "%APP_PATH%" (
    echo ============================================================
    echo  ERROR: cli-proxy-api-plus.exe not found!
    echo ============================================================
    echo.
    echo Expected path: %APP_PATH%
    echo.
    pause
    exit /b 1
)

echo ============================================================
echo  CLI Proxy API - Service Installer
echo ============================================================
echo.
echo Service Name:    %SERVICE_NAME%
echo Display Name:    %SERVICE_DISPLAY_NAME%
echo Application:     %APP_PATH%
echo Working Dir:     %APP_DIR%
echo.

:: Check if service already exists
"%NSSM_PATH%" status %SERVICE_NAME% >nul 2>&1
if %errorLevel% equ 0 (
    echo WARNING: Service '%SERVICE_NAME%' already exists!
    echo.
    set /p CONFIRM="Do you want to reinstall? (Y/N): "
    if /i "!CONFIRM!" neq "Y" (
        echo.
        echo Installation cancelled.
        pause
        exit /b 0
    )
    echo.
    echo Stopping and removing existing service...
    "%NSSM_PATH%" stop %SERVICE_NAME% >nul 2>&1
    timeout /t 2 /nobreak >nul
    "%NSSM_PATH%" remove %SERVICE_NAME% confirm >nul 2>&1
    echo Done.
    echo.
)

:: Install the service
echo Installing service...
"%NSSM_PATH%" install %SERVICE_NAME% "%APP_PATH%"
if %errorLevel% neq 0 (
    echo.
    echo ERROR: Failed to install service!
    pause
    exit /b 1
)

:: Configure service settings
echo Configuring service settings...

:: Set display name and description
"%NSSM_PATH%" set %SERVICE_NAME% DisplayName "%SERVICE_DISPLAY_NAME%"
"%NSSM_PATH%" set %SERVICE_NAME% Description "%SERVICE_DESCRIPTION%"

:: Set application directory (working directory)
"%NSSM_PATH%" set %SERVICE_NAME% AppDirectory "%APP_DIR%"

:: Set startup type to automatic
"%NSSM_PATH%" set %SERVICE_NAME% Start SERVICE_AUTO_START

:: Configure stdout/stderr logging
set LOG_DIR=%APP_DIR%\logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
"%NSSM_PATH%" set %SERVICE_NAME% AppStdout "%LOG_DIR%\service-stdout.log"
"%NSSM_PATH%" set %SERVICE_NAME% AppStderr "%LOG_DIR%\service-stderr.log"

:: Enable log rotation
"%NSSM_PATH%" set %SERVICE_NAME% AppRotateFiles 1
"%NSSM_PATH%" set %SERVICE_NAME% AppRotateOnline 1
"%NSSM_PATH%" set %SERVICE_NAME% AppRotateBytes 10485760

:: Set graceful shutdown timeout (30 seconds)
"%NSSM_PATH%" set %SERVICE_NAME% AppStopMethodSkip 0
"%NSSM_PATH%" set %SERVICE_NAME% AppStopMethodConsole 30000
"%NSSM_PATH%" set %SERVICE_NAME% AppStopMethodWindow 30000
"%NSSM_PATH%" set %SERVICE_NAME% AppStopMethodThreads 30000

echo.
echo ============================================================
echo  Service installed successfully!
echo ============================================================
echo.
echo Service Name: %SERVICE_NAME%
echo.
echo To start the service now, run:
echo   net start %SERVICE_NAME%
echo.
echo Or use Windows Services (services.msc) to manage the service.
echo.

set /p START_NOW="Start the service now? (Y/N): "
if /i "%START_NOW%" equ "Y" (
    echo.
    echo Starting service...
    "%NSSM_PATH%" start %SERVICE_NAME%
    timeout /t 2 /nobreak >nul
    "%NSSM_PATH%" status %SERVICE_NAME%
)

echo.
pause

