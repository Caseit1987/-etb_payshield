# ETB PayShield Automated Task Scheduling Loop
$scriptPath = "pipeline\stress_test.py"
$intervalSeconds = 60

Write-Host "🕒 ETB PayShield Automation Scheduler Online..." -ForegroundColor Cyan
Write-Host "Task configuration: Executing $scriptPath every $intervalSeconds seconds." -ForegroundColor Yellow
Write-Host "Press [Ctrl+C] to terminate the scheduling thread daemon." -ForegroundColor Gray

while ($true) {
    $currentTime = Get-Date -Format "HH:mm:ss"
    Write-Host "[ $currentTime ] Launching scheduled concurrency stress test execution loop..." -ForegroundColor Green
    
    # Execute the benchmark suite natively
    python $scriptPath
    
    Write-Host "[✔] Run cycle complete. Sleeping for $intervalSeconds seconds..." -ForegroundColor Gray
    Start-Sleep -Seconds $intervalSeconds
}
