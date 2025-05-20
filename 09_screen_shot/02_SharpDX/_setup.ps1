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
.\nuget.exe install SharpDX.Direct3D11


# ダウンロードしたファイルをコピー
Copy-Item ".\SharpDX.4.2.0\lib\netstandard1.1\SharpDX.dll" -Destination ".\"
Copy-Item ".\SharpDX.Direct3D11.4.2.0\lib\netstandard1.1\SharpDX.Direct3D11.dll" -Destination ".\"
Copy-Item ".\SharpDX.DXGI.4.2.0\lib\netstandard1.1\SharpDX.DXGI.dll" -Destination ".\"
