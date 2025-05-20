
Add-Type -AssemblyName System.Windows.Forms
Add-Type -Name ConsoleAPI -Namespace Win32Util -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
'

$hwnd = [Win32Util.ConsoleAPI]::GetConsoleWindow()
$nativeWindow = New-Object Windows.Forms.NativeWindow
$nativeWindow.AssignHandle($hwnd)

$result = [System.Windows.Forms.MessageBox]::show($nativeWindow,"message","title","YESNO","Info")
write-host $result


