@echo off
setlocal EnableExtensions

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrative privileges.
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "MARKER_START=# BEGIN WIN11-TELEMETRY-BLOCK"
set "MARKER_END=# END WIN11-TELEMETRY-BLOCK"

echo.
echo Disabling telemetry-related services...
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1
sc stop WerSvc >nul 2>&1
sc config WerSvc start= disabled >nul 2>&1

echo Disabling scheduled telemetry and feedback tasks...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Autochk\Proxy" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClient" /Disable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable >nul 2>&1

echo Applying telemetry/diagnostics policy restrictions...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v PeriodInNanoSeconds /t REG_QWORD /d 0 /f >nul

echo Restricting Delivery Optimization peer traffic...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul

echo Creating outbound firewall block rules for common telemetry binaries...
netsh advfirewall firewall add rule name="W11 Telemetry - CompatTelRunner Outbound" dir=out action=block program="%SystemRoot%\System32\CompatTelRunner.exe" enable=yes profile=any >nul 2>&1
netsh advfirewall firewall add rule name="W11 Telemetry - DeviceCensus Outbound" dir=out action=block program="%SystemRoot%\System32\DeviceCensus.exe" enable=yes profile=any >nul 2>&1
netsh advfirewall firewall add rule name="W11 Telemetry - WsqmCons Outbound" dir=out action=block program="%SystemRoot%\System32\wsqmcons.exe" enable=yes profile=any >nul 2>&1

echo Adding known telemetry endpoints to hosts file...
findstr /C:"%MARKER_START%" "%HOSTS_FILE%" >nul 2>&1
if errorlevel 1 (
    (
        echo %MARKER_START%
        echo 0.0.0.0 vortex-win.data.microsoft.com
        echo 0.0.0.0 settings-win.data.microsoft.com
        echo 0.0.0.0 watson.telemetry.microsoft.com
        echo 0.0.0.0 telemetry.microsoft.com
        echo 0.0.0.0 v10.events.data.microsoft.com
        echo %MARKER_END%
    )>>"%HOSTS_FILE%"
) else (
    echo Hosts block already present. Skipping hosts changes.
)

echo.
echo Telemetry and unwanted network traffic hardening has been applied.
echo Some changes may require a restart to fully take effect.
pause
