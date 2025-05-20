Set-Location -Path $PSScriptRoot
$ScreenCapturer_path = $PSScriptRoot + "\ScreenCapturer.dll"
$SystemDrawingCommon_path = $PSScriptRoot + "\System.Drawing.Common.dll"
$null = [System.Reflection.Assembly]::LoadFrom($ScreenCapturer_path)

$Refs = @(
"netstandard",
"System.Drawing",
$SystemDrawingCommon_path,
$ScreenCapturer_path
)

$Source = @"
using System;
using System.Drawing;
using ScreenCapturerNS;

public static class ScreenShot
{
    static Int32 count = 0;
    static Int32 displayIndex = 0;
    static Int32 adapterIndex = 0;

    public static void Start()
    {
        Console.WriteLine("Start");        
        ScreenCapturer.StartCapture(((System.Drawing.Bitmap bmp) => { 
                ScreenShot.count++; 
                bmp.Save("screenshot" + ScreenShot.count + ".png");            
            }),
            ScreenShot.displayIndex ,
            ScreenShot.adapterIndex );
    }

    public static void Stop()
    {
        Console.WriteLine("Stop");
        ScreenCapturer.StopCapture();
    }
}
"@

Add-Type -TypeDefinition $Source -Language CSharp -ReferencedAssemblies $Refs -Debug:$false 

# 開始
[ScreenShot]::Start()

# 1 秒スリープ
Start-Sleep -Seconds 1

# 停止
[ScreenShot]::Stop()

