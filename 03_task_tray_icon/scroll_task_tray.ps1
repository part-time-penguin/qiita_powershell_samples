Set-Location -Path $PSScriptRoot
Function ScrollTaskTrayString {
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true)][String] $message,
        [Parameter()][int] $interval = 100　# １ピクセルスクロールする間隔 ミリ秒
    )

    Add-Type -AssemblyName System.Windows.Forms

    function get_text_bitmap($message,$dist_pixel){
        $brush_bg = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0,0,0,0)) # Aを0にして透過させる 透過なのでRGBは何でもよい。
        $brush_text = New-Object Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255,255,0,0))  # Aは255で透過させない 
        $font = new-object System.Drawing.Font("メイリオ", $dist_pixel, "Bold","Pixel")

        # テキスト描画に必要なサイズを取得
        $font_size = [System.Windows.Forms.TextRenderer]::MeasureText($message, $font)
        $image_width = $font_size.Width + ($dist_pixel * 2) # 左右に余白を用意したサイズを指定
        $image_height = $font_size.Height
        $text_image = new-object System.Drawing.Bitmap([int]($image_width)),([int]($image_height))
        $text_image_graphics = [System.Drawing.Graphics]::FromImage($text_image)

        $format = [System.Drawing.StringFormat]::GenericDefault
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $rect = [System.Drawing.RectangleF]::FromLTRB(0, 0, $image_width, $image_height)

        # テキスト全体を描画する
        $text_image_graphics.FillRectangle($brush_bg, $rect)
        $text_image_graphics.DrawString($message, $font, $brush_text, $rect, $format)

        return $text_image
    }

    function get_icon_from_image($image,$dist_pixel,$scroll_index){

        $icon_image = new-object System.Drawing.Bitmap([int]($dist_pixel)),([int]($dist_pixel))
        $icon_image_graphics = [System.Drawing.Graphics]::FromImage($icon_image)

        # タスクトレイに描画する部分を切り出し
        $rect = New-Object Drawing.Rectangle 0, 0, $dist_pixel ,$dist_pixel
        $icon_image_graphics.DrawImage($image, $rect, $scroll_index, 0, $dist_pixel, $dist_pixel, ([Drawing.GraphicsUnit]::Pixel))

        $icon = [System.Drawing.Icon]::FromHandle($icon_image.GetHicon())
        $icon_image.Dispose()

        return $icon
    }

    $application_context = New-Object System.Windows.Forms.ApplicationContext
    $timer = New-Object Windows.Forms.Timer

    # タスクトレイアイコン
    $notify_icon = New-Object System.Windows.Forms.NotifyIcon
    $notify_icon.Visible = $true
    $notify_icon.Text = $message

    $script:scroll_index = 0 # 描画位置
    $image_pixel = 16 # アイコンの幅、高さのピクセル数

    # テキスト全体のイメージを生成
    $src_image = get_text_bitmap $message $image_pixel
    $notify_icon.Icon = get_icon_from_image $src_image $image_pixel 0

    # タイマーイベント.
    $timer.Enabled = $true
    $timer.Add_Tick({
        $timer.Stop()

        # 端まで描画したら終了
        if( $src_image.Width -le $script:scroll_index ){
            $application_context.ExitThread()
            return
        }

        # アイコンを入れ替える
        $notify_icon.Icon = get_icon_from_image $src_image $image_pixel $script:scroll_index

        # インデックスを更新（１ピクセルのスクロール）
        $script:scroll_index += 1

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


ScrollTaskTrayString -message "TESTテストtestてすと" -interval 50
