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
echo Restoring telemetry-related services to default startup behavior...
sc config DiagTrack start= auto >nul 2>&1
sc start DiagTrack >nul 2>&1
sc config dmwappushservice start= demand >nul 2>&1
sc start dmwappushservice >nul 2>&1
sc config WerSvc start= demand >nul 2>&1
sc start WerSvc >nul 2>&1

echo Re-enabling scheduled telemetry and feedback tasks...
schtasks /Change /TN "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\ProgramDataUpdater" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Application Experience\StartupAppTask" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Autochk\Proxy" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClient" /Enable >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Enable >nul 2>&1

echo Removing telemetry policy overrides...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v DoNotShowFeedbackNotifications /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v DisabledByGroupPolicy /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Siuf\Rules" /v PeriodInNanoSeconds /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /f >nul 2>&1

echo Removing telemetry firewall block rules...
netsh advfirewall firewall delete rule name="W11 Telemetry - CompatTelRunner Outbound" >nul 2>&1
netsh advfirewall firewall delete rule name="W11 Telemetry - DeviceCensus Outbound" >nul 2>&1
netsh advfirewall firewall delete rule name="W11 Telemetry - WsqmCons Outbound" >nul 2>&1

echo Removing telemetry hosts entries added by this project...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$path=$env:SystemRoot + '\System32\drivers\etc\hosts'; $start='# BEGIN WIN11-TELEMETRY-BLOCK'; $end='# END WIN11-TELEMETRY-BLOCK'; if(Test-Path $path){$lines=Get-Content -Path $path; $result=@(); $skip=$false; foreach($line in $lines){ if($line -eq $start){$skip=$true; continue}; if($line -eq $end){$skip=$false; continue}; if(-not $skip){$result += $line}}; Set-Content -Path $path -Value $result -Encoding ASCII }"

echo.
echo Telemetry/network hardening changes have been restored to default behavior.
echo Some changes may require a restart to fully take effect.
pause
