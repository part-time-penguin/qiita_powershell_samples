$files_args = $Args

# 日時文字列.
$datetime = (Get-Date).ToString("yyyyMMddHHmmss")

foreach($file_path in $files_args){
  Write-Output ("file_path:"+$file_path)
  if(Test-Path $file_path){
    # パスの分解.
    $folder = [System.IO.Path]::GetDirectoryName($file_path)
    $file = [System.IO.Path]::GetFileNameWithoutExtension($file_path)
    $ext = [System.IO.Path]::GetExtension($file_path)

    # コピー先パスの作成.
    $new_file_path = [System.IO.Path]::Combine($folder, $file + "_" + $datetime + $ext )

    # ファイルコピー.
    Copy-Item $file_path $new_file_path -Recurse
  }
}
