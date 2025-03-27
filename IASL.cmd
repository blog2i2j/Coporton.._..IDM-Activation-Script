@echo off
setlocal EnableDelayedExpansion
set iasver=2.0

::============================================================================
:: Coporton IDM Activation Toolkit (Activator + Registry Cleaner)
::============================================================================

mode con: cols=135 lines=40
title IDM Toolkit v%iasver%

:: Ensure Admin Privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B
)

:: Set paths
set "SCRIPT_DIR=%~dp0"
set "SRC_DIR=%SCRIPT_DIR%src\"
set "DATA_FILE=%SRC_DIR%data.bin"
set "DATAHLP_FILE=%SRC_DIR%dataHlp.bin"
set "REGISTRY_FILE=%SRC_DIR%registry.bin"
set "EXTENSIONS_FILE=%SRC_DIR%extensions.bin"
set "ascii_file=%SRC_DIR%banner_art.txt"

:: Output colors
set "RESET=[0m"
set "GREEN=[32m"
set "RED=[31m"
set "YELLOW=[33m"

chcp 65001 >nul

:: Define the number of spaces for padding
set "padding=   "

:: Loop through each line in the ASCII art file and add spaces
for /f "delims=" %%i in (%ascii_file%) do (
    echo !padding!%%i
)
echo.
echo.

:: Check IDM installation directory from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\SOFTWARE\DownloadManager" /v ExePath 2^>nul') do (
    set "DEFAULT_DEST_DIR=%%B"
)

:: Remove "IDMan.exe" from the path if found
if defined DEFAULT_DEST_DIR (
    for %%A in ("%DEFAULT_DEST_DIR%") do set "DEFAULT_DEST_DIR=%%~dpA"
    timeout /t 1 >nul
    echo %GREEN% Internet Download Manager found.%RESET%
) else (
    setlocal disabledelayedexpansion
    echo %RED% Error: Unable to find Internet Download Manager installation directory.%RESET%
    echo %YELLOW% Please ensure Internet Download Manager is installed correctly. Then run this script again. Thank you!!!%RESET%
    echo.
    echo %GREEN% You can download the latest version from here: https://www.internetdownloadmanager.com/download.html%RESET%
    echo.
    echo  Press any key to close . . .
    pause >nul
    exit
)

:: Output the IDM installed directory and version
timeout /t 1 >nul
echo %GREEN% Installed Directory: %DEFAULT_DEST_DIR%%RESET%

:: Check IDM version from the registry
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Internet Download Manager" /v DisplayVersion 2^>nul') do (
    set "IDM_VERSION=%%B"
)

if not defined IDM_VERSION (
    for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Internet Download Manager" /v DisplayVersion 2^>nul') do (
        set "IDM_VERSION=%%B"
    )
)

:: If the IDM version was not found, exit with error
if not defined IDM_VERSION (
    echo %RED% Error: Unable to retrieve the installed Internet Download Manager version. Please ensure Internet Download Manager is installed correctly.%RESET%
    pause
    exit /b
)

timeout /t 1 >nul
echo %YELLOW% Installed Internet Download Manager Version: %IDM_VERSION%%RESET%
timeout /t 1 >nul

:: MENU
:menu
::cls
echo.
echo %GREEN%  ====================================================
echo %GREEN%  :                                                :
echo %GREEN%  :  [1] Clean Previous IDM Registry Entries       :
echo %GREEN%  :  [2] Activate Internet Download Manager        :
echo %GREEN%  :  [3] Extra FileTypes Extensions                :
echo %GREEN%  :  [4] Do Everything (1 + 2 + 3)                 :
echo %GREEN%  :  [5] Exit                                      :
echo %GREEN%  :                                                :
echo %GREEN%  ====================================================%RESET%
echo.
set "choice="
set /p choice=" Choose an option (1-4): "

if "%choice%"=="1" call :CleanRegistry & call :askReturn
if "%choice%"=="2" call :ActivateIDM & call :askReturn
if "%choice%"=="3" call :AddExtentions & call :askReturn
if "%choice%"=="4" call :DoEverything & call :askReturn
if "%choice%"=="5" call :quit


echo %RED% Invalid option. Try again.%RESET%
goto :menu

::----------------------
:CleanRegistry
:: Full registry cleaning logic
call :terminateProcess "IDMan.exe"
echo %YELLOW% Cleaning IDM-related Registry Entries...%RESET%

for %%k in (
    "HKLM\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKLM\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKLM\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKLM\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKLM\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKLM\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKLM\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKLM\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKLM\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKLM\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKCU\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKCU\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKCU\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKCU\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKCU\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKCU\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKCU\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKCU\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKCU\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKCU\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKU\.DEFAULT\Software\Classes\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{7B8E9164-324D-4A2E-A46D-0165FB2000EC}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{6DDF00DB-1234-46EC-8356-27E7B2051192}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{D5B91409-A8CA-4973-9A0B-59F713D25671}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{5ED60779-4DE2-4E07-B862-974CA4FF2E9C}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{07999AC3-058B-40BF-984F-69EB1E554CA7}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{E8CF4E59-B7A3-41F2-86C7-82B03334F22A}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{9C9D53D4-A978-43FC-93E2-1C21B529E6D7}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{79873CC5-3951-43ED-BDF9-D8759474B6FD}"
    "HKU\.DEFAULT\Software\Classes\Wow6432Node\CLSID\{E6871B76-C3C8-44DD-B947-ABFFE144860D}"
    "HKLM\Software\Internet Download Manager"
    "HKLM\Software\Wow6432Node\Internet Download Manager"
    "HKCU\Software\Download Manager"
    "HKCU\Software\Wow6432Node\Download Manager"
) do reg delete %%k /f >nul 2>&1

:: Clean license values (if present)
for %%v in ("FName" "LName" "Email" "Serial" "CheckUpdtVM" "tvfrdt" "LstCheck" "scansk") do (
    reg delete "HKCU\Software\DownloadManager" /v %%v /f >nul 2>&1
)

:: Re-register user info
reg add "HKCU\SOFTWARE\DownloadManager" /v FName /t REG_SZ /d Coporton /f >nul
reg add "HKCU\SOFTWARE\DownloadManager" /v LName /t REG_SZ /d WorkStation /f >nul

echo %GREEN% Registry cleanup completed.%RESET%
exit /b

::----------------------
:ActivateIDM
call :verifyFile "%DATA_FILE%" "data.bin"
call :verifyFile "%DATAHLP_FILE%" "dataHlp.bin"
call :verifyFile "%REGISTRY_FILE%" "registry.bin"
call :verifyDestinationDirectory
call :terminateProcess "IDMan.exe"
regedit /s "%REGISTRY_FILE%"
copy "%DATA_FILE%" "%DEFAULT_DEST_DIR%IDMan.exe" >nul
copy "%DATAHLP_FILE%" "%DEFAULT_DEST_DIR%IDMGrHlp.exe" >nul
echo %GREEN% Congratulations. Internet Download Manager Activated Successfully.%RESET%
exit /b

:verifyFile
if not exist "%~1" echo %RED% Missing: %~2%RESET% & pause & exit /b
exit /b

:verifyDestinationDirectory
if not exist "%DEFAULT_DEST_DIR%" echo %RED% Destination not found.%RESET% & pause & exit /b
exit /b

:terminateProcess
taskkill /F /IM %~1 >nul 2>&1
exit /b

:AddExtentions
regedit /s "%EXTENSIONS_FILE%"
echo %GREEN% Extra FileTypes Extensions updated successfully.%RESET%
exit /b

::----------------------
:DoEverything
call :CleanRegistry
call :ActivateIDM
call :AddExtentions
echo.
echo %GREEN% All tasks completed successfully!%RESET%
echo.
exit /b

::----------------------
:askReturn
set /p back=" Return to main menu? (Y/N): "
if /i "%back%"=="Y" goto :menu
if /i "%back%"=="N" call :quit
goto :askReturn

::----------------------
:quit
    echo.
    echo %GREEN% Thank you for using Coporton IDM Activation Toolkit. Exiting...%RESET%
    timeout /t 2 >nul
    exit
    