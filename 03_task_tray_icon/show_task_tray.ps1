Set-Location -Path $PSScriptRoot
Function ShowTaskTrayString {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)][String] $message,
        [Parameter()][int] $interval = 1000
    )

    Write-Host $message

    Add-Type -AssemblyName System.Windows.Forms

    $application_context = New-Object System.Windows.Forms.ApplicationContext
    $timer = New-Object Windows.Forms.Timer

    # タスクトレイアイコン
    $notify_icon = New-Object System.Windows.Forms.NotifyIcon
    $notify_icon.Visible = $true
    $notify_icon.Text = $message
    function get_char_icon($image_text){

        Write-Host $image_text
        $image_pixel = 16 # アイコンの幅、高さのピクセル数 
        
        $brush_bg = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0,0,0,0)) # Aを0にして透過させる 透過なのでRGBは何でもよい。
        $brush_text = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,0,255,0)) # Aは255で透過させない 
        $font = new-object System.Drawing.Font("メイリオ", $image_pixel, "Bold","Pixel")
        
        $icon_image = new-object System.Drawing.Bitmap([int]($image_pixel)),([int]($image_pixel))
        $image_graphics = [System.Drawing.Graphics]::FromImage($icon_image)
        
        $format = [System.Drawing.StringFormat]::GenericDefault
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $rect = [System.Drawing.RectangleF]::FromLTRB(0, 0, $image_pixel, $image_pixel)

        # テキスト全体を描画する
        $image_graphics.FillRectangle($brush_bg, $rect)
        $image_graphics.DrawString($image_text, $font, $brush_text, $rect, $format)
        $icon_image.save($PSScriptRoot + "\icon.bmp", [System.Drawing.Imaging.ImageFormat]::Bmp)
        
        $icon = [System.Drawing.Icon]::FromHandle($icon_image.GetHicon())
        $icon_image.Dispose()

        return $icon
    }
      
    $script:message_char_index = 0
    $notify_icon.Icon = get_char_icon($message.substring(0,1))

    # タイマーイベント.
    $timer.Enabled = $true
    $timer.Add_Tick({
        $timer.Stop()

        if( $message.Length -le $script:message_char_index ){
            $application_context.ExitThread()
            return
        }

        # アイコンを入れ替える
        $notify_icon.Icon = get_char_icon($message.substring($script:message_char_index,1))

        # インデックスを更新
        $script:message_char_index += 1

        # インターバルを再設定してタイマー再開
        $timer.Interval = $interval
        $timer.Start()
    })

    $timer.Interval = 1
    $timer.Start()

    [void][System.Windows.Forms.Application]::Run($application_context)

    $timer.Stop()
    $notify_icon.Visible = $false
}

ShowTaskTrayString -message "TESTテストtestてすと" -interval 1000