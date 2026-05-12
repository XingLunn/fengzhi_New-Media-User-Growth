# 知识库文件监听器 - 监控 content/ 变化，自动转换 + 构建 + 推送
param($Interval = 30)

$project = "C:\Users\Administrator\quartz-knowledge"
$content = Join-Path $project "content"
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $content
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::DirectoryName

$lastBuild = Get-Date
$pending = $false
$timer = New-Object System.Timers.Timer
$timer.Interval = $Interval * 1000
$timer.AutoReset = $true

$action = {
    if ($pending) {
        $pending = $false
        $elapsed = [int]((Get-Date) - $lastBuild).TotalSeconds
        Write-Host "Build triggered (last: ${elapsed}s ago)" -ForegroundColor Yellow
        Set-Location $project
        powershell -ExecutionPolicy Bypass -File "$project\convert.ps1" 2>&1 | Out-Null
        $result = npx quartz build 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Build OK" -ForegroundColor Green
            git add -A 2>&1 | Out-Null
            $status = git status --short
            if ($status) {
                git commit -m "Auto: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" 2>&1 | Out-Null
                git push 2>&1 | Out-Null
                Write-Host "Pushed" -ForegroundColor Green
            }
        } else {
            Write-Host "Build FAILED" -ForegroundColor Red
        }
        $lastBuild = Get-Date
    }
}

$null = Register-ObjectEvent $watcher "Created" -Action $action
$null = Register-ObjectEvent $watcher "Changed" -Action $action
$null = Register-ObjectEvent $watcher "Deleted" -Action $action
$null = Register-ObjectEvent $watcher "Renamed" -Action $action

$timerEvent = Register-ObjectEvent $timer "Elapsed" -Action { $pending = $true }
$timer.Start()

Write-Host "File watcher started" -ForegroundColor Green
Write-Host "  Watching: $content" -ForegroundColor DarkGray
Write-Host "  Debounce: ${Interval}s" -ForegroundColor DarkGray
Write-Host "  Press Ctrl+C to stop" -ForegroundColor DarkGray

try {
    while ($true) { Start-Sleep -Seconds 5 }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $timer.Stop()
    $watcher.Dispose()
    $timer.Dispose()
    Write-Host "Watcher stopped" -ForegroundColor Yellow
}
