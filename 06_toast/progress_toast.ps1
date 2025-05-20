

Function ShowProgressToast {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)][String] $tag,
        [Parameter(Mandatory=$true)][String] $group,
        [Parameter(Mandatory=$true)][String] $title,
        [Parameter(Mandatory=$true)][String] $message,
        [Parameter(Mandatory=$true)][String] $progressTitle
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
            <progress value="{progressValue}" title="{progressTitle}" valueStringOverride="{progressValueString}" status="{progressStatus}" />
        </binding>
    </visual>
</toast>
"@

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($content)
    $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
    $toast.Tag = $tag
    $toast.Group = $group
    $toast_data = New-Object 'system.collections.generic.dictionary[string,string]'
    $toast_data.add("progressTitle", $progressTitle)
    $toast_data.add("progressValue", "")
    $toast_data.add("progressValueString", "")
    $toast_data.add("progressStatus", "")
    $toast.Data = [Windows.UI.Notifications.NotificationData]::new($toast_data)
    $toast.Data.SequenceNumber = 1
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app_id).Show($toast)
}

Function UpdateProgessToast {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)][String] $tag,
        [Parameter(Mandatory=$true)][String] $group,
        [Parameter(Mandatory=$true)][String] $value,
        [Parameter(Mandatory=$true)][String] $message,
        [Parameter(Mandatory=$true)][String] $status
    )
    $app_id = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'

    $toast_data = New-Object 'system.collections.generic.dictionary[string,string]'
    $toast_data.add("progressValue", $value)
    $toast_data.add("progressValueString", $message)
    $toast_data.add("progressStatus", $status)
    $progress_data = [Windows.UI.Notifications.NotificationData]::new($toast_data)
    $progress_data.SequenceNumber = 2

    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app_id).Update($progress_data, $tag , $group) | Out-Null

}


$tag_name = "my_tag"
$group_name = "my_group"
$max_count = 5

# 表示
ShowProgressToast -tag $tag_name -group $group_name -title "title" -message "message" -progressTitle "progress"

# 更新するループ
for($index=0; $index -le $max_count; $index++) {
    $value = $index / $max_count
    $message = "[" + $index + "/" + $max_count + "]"

    UpdateProgessToast -tag $tag_name -group $group_name -value $value -message $message -status "status"

    Start-Sleep -Seconds 1
}

