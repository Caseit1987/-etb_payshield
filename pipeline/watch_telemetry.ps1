# ETB PayShield Live Task Orchestration Daemon (With Log Rotation Handling)
$logPath = "gate\intercept_stream.log"
$archiveDir = "gate\archive"
$maxSizeBytes = 5120  # 5KB Threshold for Automated Log Rotation Testing

Write-Host "📡 ETB PayShield Background Task Orchestration Engine Active..." -ForegroundColor Cyan
Write-Host "Monitoring log target: $logPath" -ForegroundColor Yellow

if (-not (Test-Path $logPath)) { New-Item -ItemType File -Path $logPath -Force | Out-Null }
if (-not (Test-Path $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }

$lineCount = (Get-Content $logPath).Length

while ($true) {
    Start-Sleep -Seconds 1
    if (Test-Path $logPath) {
        # Check if Log Rotation Condition is met
        $fileSize = (Get-Item $logPath).Length
        if ($fileSize -gt $maxSizeBytes) {
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $archivePath = "$archiveDir\intercept_stream_$timestamp.log"
            Move-Item -Path $logPath -Destination $archivePath -Force
            New-Item -ItemType File -Path $logPath -Force | Out-Null
            $lineCount = 0
            Write-Host "[🔄] Log Size Limit Exceeded. Automated log rotation executed: $archivePath" -ForegroundColor Cyan
            continue
        }

        $currentLines = Get-Content $logPath
        if ($currentLines.Length -gt $lineCount) {
            $newEntries = $currentLines[$lineCount..($currentLines.Length - 1)]
            foreach ($entry in $newEntries) {
                if ($entry -match 'INTERCEPTED: src=(?<src>[^ ]+) dst_port=(?<port>\d+) method=(?<method>[^ ]+)') {
                    $src = $Matches.src
                    $port = $Matches.port
                    $method = $Matches.method
                    
                    Write-Host "[⚠️] Threat Intercept Detected: src=$src dst_port=$port method=$method. Triggering STIX parser..." -ForegroundColor Red
                    python pipeline\stix_parser.py --src $src --port $port --method $method --anomalous True
                }
            }
            $lineCount = $currentLines.Length
        }
    }
}
