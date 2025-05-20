
Function ShowImageToast {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)][String] $title,
        [Parameter(Mandatory=$true)][String] $message,
        [Parameter(Mandatory=$true)][String] $detail,
        [Parameter(Mandatory=$true)][String] $icon_path,
        [Parameter(Mandatory=$true)][String] $hero_path
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

    $app_id = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $content = @"
<?xml version="1.0" encoding="utf-8"?>
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$($title)</text>
            <text>$($message)</text>
            <text>$($detail)</text>
            <image placement="appLogoOverride" hint-crop="circle" src="$($icon_path)"/>
            <image placement="hero" src="$($hero_path)"/>
        </binding>
    </visual>
</toast>
"@
    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($content)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app_id).Show($toast)
}

# C:\Windows\Web\Wallpaper の下の画像を探す 
$wallpaper_path = "C:\Windows\Web\Wallpaper"
$png_files = Get-ChildItem -Path $wallpaper_path -Filter *.jpg -Recurse
# ランダムに1つ選択
$random_file = $png_files | Get-Random

ShowImageToast -title "title" -message "message" -detail "detail" -icon_path $random_file.FullName -hero_path $random_file.FullName
