
Add-Type -AssemblyName System.Windows.Forms

function main(){
  $mutex = New-Object System.Threading.Mutex($false, "Global\mutex_awake")
  # 多重起動チェック
  if ($mutex.WaitOne(0, $false)){    
    # SetThreadExecutionState API の準備(スリープ抑制)
    $ES_SYSTEM_REQUIRED = [uint32]"0x00000001"
    $ES_CONTINUOUS = [uint32]"0x80000000"
    $ES_DISPLAY_REQUIRED = [uint32]"0x80000002"
    $awakecode = '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint esFlags);'
    $awakefunc = Add-Type -MemberDefinition $awakecode -namespace Win32Functions -name _SetThreadExecutionState -PassThru
    $null = $awakefunc::SetThreadExecutionState($ES_SYSTEM_REQUIRED -bor $ES_CONTINUOUS);    # スリープ抑制

    # Win32ShowWindowAsync API の準備(タスクバー非表示)
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncfunc = Add-Type -MemberDefinition $windowcode -namespace Win32Functions -name Win32ShowWindowAsync -PassThru
    $null = $asyncfunc::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
    
    $application_context = New-Object System.Windows.Forms.ApplicationContext
    $timer = New-Object Windows.Forms.Timer
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path # icon用
    $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $notify_icon = New-Object System.Windows.Forms.NotifyIcon
    $notify_icon.Icon = $icon
    $notify_icon.Visible = $true
    $notify_icon.Text = "awake"
    $menu_item_exit = New-Object System.Windows.Forms.MenuItem
    $menu_item_exit.Text = "awake - Exit"
    $notify_icon.ContextMenu = New-Object System.Windows.Forms.ContextMenu
    $notify_icon.contextMenu.MenuItems.AddRange($menu_item_exit)
    $menu_item_exit.add_Click({
      $application_context.ExitThread()
    })

    # タイマーイベント
    $timer.Enabled = $true
    $timer.Add_Tick({      
      $null = $awakefunc::SetThreadExecutionState($ES_DISPLAY_REQUIRED); # 定期的に呼び出すことディスプレイ状態維持
    })

    $timer.Interval = 30 * 1000 # 30秒間隔
    $timer.Start()
    [void][System.Windows.Forms.Application]::Run($application_context)
    $timer.Stop()
    $null = $awakefunc::SetThreadExecutionState($ES_CONTINUOUS);    # 抑制解除
    $notify_icon.Visible = $false
    $mutex.ReleaseMutex()
  }
  $mutex.Close()
}

main

