@echo off
setlocal EnableDelayedExpansion

:: ============================================================
:: CLI Proxy API - Windows Service Uninstaller
:: ============================================================

:: Service configuration
set SERVICE_NAME=CLIProxyAPI

:: Get the directory where this script is located
set SCRIPT_DIR=%~dp0
set SCRIPT_DIR=%SCRIPT_DIR:~0,-1%

:: Set NSSM path
set NSSM_PATH=%SCRIPT_DIR%\nssm-2.24\win64\nssm.exe

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

echo ============================================================
echo  CLI Proxy API - Service Uninstaller
echo ============================================================
echo.

:: Check if service exists
"%NSSM_PATH%" status %SERVICE_NAME% >nul 2>&1
if %errorLevel% neq 0 (
    echo Service '%SERVICE_NAME%' is not installed.
    echo.
    pause
    exit /b 0
)

:: Get current status
echo Current service status:
"%NSSM_PATH%" status %SERVICE_NAME%
echo.

:: Confirm uninstall
set /p CONFIRM="Are you sure you want to uninstall the service? (Y/N): "
if /i "%CONFIRM%" neq "Y" (
    echo.
    echo Uninstallation cancelled.
    pause
    exit /b 0
)

echo.

:: Stop the service if running
echo Stopping service...
"%NSSM_PATH%" stop %SERVICE_NAME% >nul 2>&1
timeout /t 3 /nobreak >nul

:: Remove the service
echo Removing service...
"%NSSM_PATH%" remove %SERVICE_NAME% confirm
if %errorLevel% neq 0 (
    echo.
    echo ERROR: Failed to remove service!
    echo.
    echo Try stopping the service manually first:
    echo   net stop %SERVICE_NAME%
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  Service uninstalled successfully!
echo ============================================================
echo.
echo The service '%SERVICE_NAME%' has been removed.
echo.
echo Note: Log files in the 'logs' folder were not deleted.
echo You may remove them manually if no longer needed.
echo.

pause

