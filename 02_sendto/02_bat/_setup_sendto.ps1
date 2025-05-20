
function create_sendto_shortcut($script_path,$link_name,$work_path){
    # sendtoのパスを取得.
    $sendto_path = [Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo)
    $sendto_shortcut_path = [System.IO.Path]::Combine($sendto_path, $link_name + ".lnk" )

    # ショートカットの有無確認.
    $is_shortcut = (Test-Path $sendto_shortcut_path)
    if(!$is_shortcut){
        # ショートカット生成.
        $WshShell = New-Object -ComObject WScript.Shell
        $ShortCut = $WshShell.CreateShortcut($sendto_shortcut_path)
        $ShortCut.TargetPath = $script_path
        $ShortCut.WorkingDirectory = $work_path
        # $ShortCut.WindowStyle = 7 # 最小化する場合はコメント外す
        $ShortCut.Save()
    }
}


# 実行するbatファイルパス.
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$sendto_script = [System.IO.Path]::Combine($current_path, "sendto.bat")

create_sendto_shortcut $sendto_script "日時追加コピー" $current_path

