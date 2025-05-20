Set-Location -Path $PSScriptRoot

#nuget.exe をダウンロード
$nuget_path = ".\nuget.exe"
$url = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"

# 存在チェック
if (Test-Path $nuget_path) {
    Write-Host "nuget.exe は既に存在します"
} else {
    # ダウンロード
    Invoke-WebRequest -Uri $url -OutFile $nuget_path
}

# ダウンロードした nuget.exe を実行
.\nuget.exe install log4net


# ダウンロードしたファイルをコピー
Copy-Item ".\log4net.3.1.0\lib\net462\log4net.dll" -Destination ".\"





