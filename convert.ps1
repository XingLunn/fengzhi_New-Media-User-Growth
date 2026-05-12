# 知识库转换脚本
# 将 文案(.docx) 和 数据(.xlsx) 转换为 Markdown 后移入知识库
param([switch]$Watch)

$desktop = [Environment]::GetFolderPath("Desktop")
$inbox = Join-Path $desktop "知识库-待处理"
$inboxWenan = Join-Path $inbox "文案"
$inboxData = Join-Path $inbox "数据"
$done = Join-Path $inbox "已处理"
$project = "C:\Users\Administrator\quartz-knowledge"
$content = Join-Path $project "content\新媒体增长"
$blogDir = Join-Path $content "01-小红书运营\帖子库"
$dataDir = Join-Path $content "01-小红书运营\数据"

function Convert-WordToMD {
    param($file)
    $name = [IO.Path]::GetFileNameWithoutExtension($file)
    $outDir = Join-Path $blogDir "2026-05"
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory $outDir -Force | Out-Null }
    $out = Join-Path $outDir "$name.md"
    Write-Host "  Word -> Markdown: $name" -ForegroundColor Cyan
    pandoc $file -f docx -t markdown-smart --wrap=none -o $out 2>&1 | Out-Null
    $body = Get-Content $out -Raw -Encoding UTF8
    $title = $name -replace '^\d+[\.\s]*', ''
    $front = "---`ntitle: $title`ndate: $(Get-Date -Format 'yyyy-MM-dd')`ntype: auto`n---`n"
    $front + $body | Set-Content $out -Encoding UTF8
    Move-Item $file (Join-Path $done $($file.Name)) -Force
    Write-Host "    Done: $out" -ForegroundColor Green
}

function Convert-ExcelToMD {
    param($file)
    $name = [IO.Path]::GetFileNameWithoutExtension($file)
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $out = Join-Path $dataDir "$name.md"
    try {
        $wb = $excel.Workbooks.Open($file.FullName)
        $sheet = $wb.Worksheets.Item(1)
        $used = $sheet.UsedRange
        $rows = $used.Rows.Count
        $cols = $used.Columns.Count
        $data = @()
        for ($r = 1; $r -le $rows; $r++) {
            $row = @()
            for ($c = 1; $c -le $cols; $c++) {
                $row += $sheet.Cells.Item($r, $c).Text
            }
            $data += $row
        }
        $wb.Close($false)
        if ($data.Count -eq 0) { return }
        $md = @()
        $md += "# $name"
        $md += ""
        $md += "> auto-generated $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        $md += ""
        $header = $data[0]
        $md += "| " + ($header -join " | ") + " |"
        $sep = ($header | ForEach-Object { "---" }) -join " | "
        $md += "| $sep |"
        for ($r = 1; $r -lt $data.Count; $r++) {
            $row = $data[$r]
            $md += "| " + ($row -join " | ") + " |"
        }
        $md -join "`n" | Set-Content $out -Encoding UTF8
        Move-Item $file (Join-Path $done $($file.Name)) -Force
        Write-Host "    Done: $out" -ForegroundColor Green
    }
    catch {
        Write-Host "    FAIL: $_" -ForegroundColor Red
    }
    finally {
        $excel.Quit()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
}

Write-Host "Scanning inbox..." -ForegroundColor Yellow
$found = $false

Get-ChildItem $inboxWenan -Filter "*.docx" -ErrorAction SilentlyContinue | ForEach-Object {
    $found = $true
    Convert-WordToMD $_
}

Get-ChildItem $inboxData -Filter "*.xlsx" -ErrorAction SilentlyContinue | ForEach-Object {
    $found = $true
    Convert-ExcelToMD $_
}

Get-ChildItem $inboxData -Filter "*.csv" -ErrorAction SilentlyContinue | ForEach-Object {
    $found = $true
    $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
    $out = Join-Path $dataDir "$name.md"
    $csv = Import-Csv $_.FullName
    if ($csv) {
        $headers = $csv[0].PSObject.Properties.Name
        $md = @()
        $md += "# $name"
        $md += ""
        $md += "| " + ($headers -join " | ") + " |"
        $md += "| " + ($headers | ForEach-Object { "---" }) -join " | " + " |"
        foreach ($row in $csv) {
            $vals = $headers | ForEach-Object { $row.$_ }
            $md += "| " + ($vals -join " | ") + " |"
        }
        $md -join "`n" | Set-Content $out -Encoding UTF8
        Move-Item $_.FullName (Join-Path $done $($_.Name)) -Force
        Write-Host "  CSV -> Markdown: $name" -ForegroundColor Cyan
        Write-Host "    Done: $out" -ForegroundColor Green
    }
}

if (-not $found) {
    Write-Host "  (no pending files)" -ForegroundColor DarkGray
}

Write-Host "Done." -ForegroundColor Green
