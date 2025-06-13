# xxx.zip.001 からの連番のファイルで結合

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$files = Get-ChildItem $scriptPath | Where-Object { $_.Name -match '.*\.zip\.[0-9]{3}$' }

if ($files.Length -eq 0) {
    Write-Host "結合対象ファイルがありません"
    return
}

$outputPath = Join-Path $scriptPath "$($files[0].BaseName)_join.zip"
$fs = New-Object System.IO.FileStream($outputPath, 'Create')
foreach ($item in $files) {
    Write-Host "結合対象ファイル: $($item.Name)"
    $filePath = Join-Path $scriptPath $item.Name
    $data = [System.IO.File]::ReadAllBytes($filePath)
    $fs.Write($data, 0, $data.Length)
}
$fs.Dispose()
