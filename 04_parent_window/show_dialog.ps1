
Add-Type -AssemblyName PresentationFramework
Add-Type -Name ConsoleAPI -Namespace Win32Util -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Test"
  Height="200" Width="300" >
</Window>
'@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$wih = New-Object System.Windows.Interop.WindowInteropHelper($window)
$wih.Owner = [Win32Util.ConsoleAPI]::GetConsoleWindow()

$window.ShowDialog() | Out-Null
