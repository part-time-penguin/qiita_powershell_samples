
# 日本語のショートカットを作成する場合は UTF-8 with BOM で保存すること.

function create_desktop_shortcut($script_path, $name){
    # Desktopのパスを取得.
    $desktop_path = [Environment]::GetFolderPath([Environment+SpecialFolder]::Desktop)
    $desktop_shortcut_path = [System.IO.Path]::Combine($desktop_path, $name + ".lnk" )

    # ショートカットの有無確認.
    if(![System.IO.File]::Exists($desktop_shortcut_path)){
        # ショートカット生成.
        $WshShell = New-Object -ComObject WScript.Shell
        $ShortCut = $WshShell.CreateShortcut($desktop_shortcut_path)
        $ShortCut.TargetPath = "powershell.exe"
        $ShortCut.Arguments = "-NoProfile -ExecutionPolicy Unrestricted " + $script_path
        # $ShortCut.WindowStyle = 7 # 最小化する場合はコメント外す
        $ShortCut.Save()
    }
}

# 実行するps1ファイルのフルパス.
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$sendto_script = [System.IO.Path]::Combine($current_path, "sendto.ps1")

create_desktop_shortcut $sendto_script "日時追加コピー"
