
# 日本語のショートカットを作成する場合は UTF-8 with BOM で保存すること.

function create_sendto_shortcut($script_path, $name){
    # sendtoのパスを取得.
    $sendto_path = [Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo)
    $sendto_shortcut_path = [System.IO.Path]::Combine($sendto_path, $name + ".lnk" )

    Write-Host $sendto_shortcut_path

    # ショートカットの有無確認.
    if(![System.IO.File]::Exists($sendto_shortcut_path)){
        # ショートカット生成.
        $WshShell = New-Object -ComObject WScript.Shell
        $ShortCut = $WshShell.CreateShortcut($sendto_shortcut_path)
        $ShortCut.TargetPath = "powershell.exe"
        $ShortCut.Arguments = "-NoProfile -ExecutionPolicy Unrestricted " + $script_path
        # $ShortCut.WindowStyle = 7 # 最小化する場合はコメント外す
        $ShortCut.Save()
    }
}

# 実行するps1ファイルのフルパス.
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$sendto_script = [System.IO.Path]::Combine($current_path, "sendto.ps1")

create_sendto_shortcut $sendto_script "日時追加コピー"
