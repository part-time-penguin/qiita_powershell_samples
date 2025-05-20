Add-Type -AssemblyName System.Windows.Forms

# 定数定義
$TIMER_INTERVAL = 10 * 1000 # timer_function実行間隔(ミリ秒)
$MUTEX_NAME = "Global\mutex" # 多重起動チェック用

function timer_function($notify){
  # ここに定期実行する処理を実装

  $datetime = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
  Write-Host "timer_function "  $datetime

  # ツールチップに登録
  $notify.Text = $datetime

  # バルーンで表示
  $notify.BalloonTipIcon = 'Info'
  $notify.BalloonTipText = $datetime
  $notify.BalloonTipTitle = 'sample'
  $notify.ShowBalloonTip(1000)
}

function main(){
  $mutex = New-Object System.Threading.Mutex($false, $MUTEX_NAME)
  # 多重起動チェック
  if ($mutex.WaitOne(0, $false)){
    # タスクバー非表示
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

    $application_context = New-Object System.Windows.Forms.ApplicationContext
    $timer = New-Object Windows.Forms.Timer
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path # icon用
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)

    # タスクトレイアイコン
    $notify_icon = New-Object System.Windows.Forms.NotifyIcon
    $notify_icon.Icon = $icon
    $notify_icon.Visible = $true

    # アイコンクリック時のイベント
    $notify_icon.add_Click({
      if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
        # タイマーで実装されているイベントを即時実行する
        $timer.Stop()
        $timer.Interval = 1
        $timer.Start()
      }
    })

    # メニュー
    $menu_item_exit = New-Object System.Windows.Forms.MenuItem
    $menu_item_exit.Text = "Exit"
    $notify_icon.ContextMenu = New-Object System.Windows.Forms.ContextMenu
    $notify_icon.contextMenu.MenuItems.AddRange($menu_item_exit)

    # Exitメニュークリック時のイベント
    $menu_item_exit.add_Click({
      $application_context.ExitThread()
    })

    # タイマーイベント.
    $timer.Enabled = $true
    $timer.Add_Tick({
      $timer.Stop()

      timer_function($notify_icon)

      # インターバルを再設定してタイマー再開
      $timer.Interval = $TIMER_INTERVAL
      $timer.Start()
    })

    $timer.Interval = 1
    $timer.Start()

    [void][System.Windows.Forms.Application]::Run($application_context)

    $timer.Stop()
    $notify_icon.Visible = $false
    $mutex.ReleaseMutex()
  }
  $mutex.Close()
}

main
