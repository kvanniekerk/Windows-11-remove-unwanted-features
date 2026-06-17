@echo off
:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrative privileges.
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set execution policy to RemoteSigned for the current user (for running JavaScript using Node.js or PowerShell scripts if needed)
::powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
::echo Execution policy set to RemoteSigned.

:: Disable Bing search in the Start Menu
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f
echo Registry keys added successfully, Bing search results will no longer appear in the start menu.

:: Remove Search icon from taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 0 /f
echo Taskbar Search icon removed.

:: Enable full right-click context menu (classic)
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
echo Full right-click context menu enabled.

:: Disable Widgets
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f
echo Widgets disabled.

:: Remove Task View (desktop switch) button
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowTaskViewButton /t REG_DWORD /d 0 /f
echo Task View button removed.

:: Remove Taskbar Chat
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarMn /t REG_DWORD /d 0 /f
echo Taskbar Chat removed.

:: Move taskbar to the left (classic position)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f
echo Taskbar moved to the left.

:: Show all system tray icons
:: reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v EnableAutoTray /t REG_DWORD /d 0 /f
:: echo All system tray icons will be shown.

:: Show file extensions in File Explorer
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f
echo File extensions will be shown in File Explorer.

pause