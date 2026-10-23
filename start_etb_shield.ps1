# ETB PayShield Unified Control Script
$TargetHost = $env:GATE_HOST
$TargetPort = $env:GATE_PORT

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "[*] Launching ETB PayShield System Infrastructure..." -ForegroundColor Cyan
Write-Host "[*] Interface: http://$($TargetHost):$($TargetPort)" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

# Check if environment variables are fully populated before starting process handles
if (-not $env:GATE_ENGINE_API_KEY) {
    Write-Error "CRITICAL: GATE_ENGINE_API_KEY environment variable is missing from session state. Aborting."
    Exit
}

# Start the LayerZero validation gate proxy component as a background task job
$GateJob = Start-Job -Name "ETB_Proxy_Gate" -ScriptBlock {
    python "C:\Users\casei\Desktop\etb_payshield\gate\proxy_listener.py"
}

Write-Host "[+] LayerZero Verification Gate spawned safely in background process context." -ForegroundColor Green
Write-Host "[*] Run 'Get-Job' or 'Receive-Job -Name ETB_Proxy_Gate' to monitor execution stream." -ForegroundColor Gray
Write-Host "[*] To close infrastructure down completely, execute: Stop-Job -Name ETB_Proxy_Gate" -ForegroundColor Gray
Write-Host "====================================================" -ForegroundColor Cyan
