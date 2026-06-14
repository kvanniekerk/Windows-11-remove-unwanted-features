@echo off
set "startupFolder=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

:: 1. Create the silent VBScript wrapper in the Startup folder
(
    echo Set WshShell = CreateObject^("WScript.Shell"^)
    echo WshShell.Run chr^(34^) ^& "%startupFolder%\removewindowatermark.bat" ^& chr^(34^), 0
    echo Set WshShell = Nothing
) > "%startupFolder%\silent_launch.vbs"

:: 2. Create the actual watermark removal batch file (now completely stripped of UI echo commands)
(
    echo @echo off
    echo taskkill /F /IM explorer.exe
    echo start explorer.exe
    echo exit
) > "%startupFolder%\removewindowatermark.bat"

:: 3. Success message for the initial setup
echo ===================================================
echo  Setup Complete! 
echo ===================================================
echo  The watermark removal will now run 100%% silently
echo  in the background on every future startup.
echo.
timeout /t 3 /nobreak
exit