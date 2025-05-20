Set-Location -Path $PSScriptRoot
$SharpDX_dll_path =  $PSScriptRoot + "\SharpDX.dll"
$SharpDX_DXGI_dll_path =  $PSScriptRoot + "\SharpDX.DXGI.dll"
$SharpDX_Direct3D11_dll_path =  $PSScriptRoot + "\SharpDX.Direct3D11.dll"
$null = [System.Reflection.Assembly]::LoadFrom($SharpDX_dll_path);
$null = [System.Reflection.Assembly]::LoadFrom($SharpDX_DXGI_dll_path);
$null = [System.Reflection.Assembly]::LoadFrom($SharpDX_Direct3D11_dll_path);


$Refs = @(
"System.Runtime",
"System.IO",
"System.Drawing",
$SharpDX_dll_path,
$SharpDX_DXGI_dll_path,
$SharpDX_Direct3D11_dll_path
)


$Source = @"
using System;
using SharpDX;
using SharpDX.Direct3D11;
using SharpDX.DXGI;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class ScreenshotCapture : IDisposable
{
    private SharpDX.Direct3D11.Device _device;
     private OutputDuplication _duplication;
     private Texture2D _gdiImage;
     private Texture2D _destImage;
     private Texture2DDescription _textureDesc;
     private Texture2DDescription _textureGdiDesc;

     [DllImport("user32.dll")]
     private static extern bool GetCursorInfo(out CURSORINFO pci);
     [StructLayout(LayoutKind.Sequential)]
     private struct CURSORINFO
     {
          public int cbSize;
          public int flags;
          public IntPtr hCursor;
          public POINT ptScreenPos;
     }
     private struct POINT
     {
          public int X;
          public int Y;
     }
     private const int CURSOR_SHOWING = 0x00000001;

     [DllImport("user32.dll")]
     private static extern IntPtr DrawIconEx(IntPtr hdc, int xLeft, int yTop, IntPtr hIcon, int cxWidth, int cyWidth, int istepIfAniCur, IntPtr hbrFlickerFreeDraw, int diFlags);
     private const int DI_NORMAL = 0x00000003;
     private const int DI_DEFAULTSIZE = 0x00000008;
     
     public ScreenshotCapture()
     {
          using (Factory1 _factory = new Factory1())
          {
               using (Adapter1 _adapter = _factory.GetAdapter1(0))
               {
                    _device = new SharpDX.Direct3D11.Device(_adapter);
                    using (Output _output = _adapter.GetOutput(0))
                    {
                         using (Output1 _output1 = _output.QueryInterface<Output1>())
                         {
                              _duplication = _output1.DuplicateOutput(_device);

                              _textureDesc = new Texture2DDescription
                              {
                                   CpuAccessFlags = CpuAccessFlags.Read | CpuAccessFlags.Write,
                                   BindFlags = BindFlags.None,
                                   Format = Format.B8G8R8A8_UNorm,
                                   Width = _output.Description.DesktopBounds.Right,
                                   Height = _output.Description.DesktopBounds.Bottom,
                                   MipLevels = 1,
                                   ArraySize = 1,
                                   SampleDescription = { Count = 1, Quality = 0 },
                                   Usage = ResourceUsage.Staging,
                                   OptionFlags = ResourceOptionFlags.None
                              };

                              _textureGdiDesc = new Texture2DDescription
                              {
                                   CpuAccessFlags = CpuAccessFlags.None,
                                   BindFlags = BindFlags.RenderTarget,
                                   Format = Format.B8G8R8A8_UNorm,
                                   Width = _output.Description.DesktopBounds.Right,
                                   Height = _output.Description.DesktopBounds.Bottom,
                                   MipLevels = 1,
                                   ArraySize = 1,
                                   SampleDescription = { Count = 1, Quality = 0 },
                                   Usage = ResourceUsage.Default,
                                   OptionFlags = ResourceOptionFlags.GdiCompatible
                              };

                              _gdiImage = new Texture2D(_device, _textureGdiDesc);
                              _destImage = new Texture2D(_device, _textureDesc);
                         }
                    };
               };
          };

          CaptureScreen(""); // 初回は黒画像になるので読み捨てる
     }

     public void CaptureScreen(string outputFile)
     {
          SharpDX.DXGI.Resource desktopResource = null; // デスクトップのイメージが格納される
          OutputDuplicateFrameInformation frameInfo = new OutputDuplicateFrameInformation();

          if (_duplication.TryAcquireNextFrame(1000, out frameInfo, out desktopResource).Success)
          {
               using (Texture2D desktopImage = desktopResource.QueryInterface<Texture2D>())
               {
                    _device.ImmediateContext.CopyResource(desktopImage, _gdiImage);

                    using (Surface1 surface1 = _gdiImage.QueryInterface<Surface1>())
                    {
                         CURSORINFO cursorInfo;
                         cursorInfo.cbSize = Marshal.SizeOf(typeof(CURSORINFO));
                         GetCursorInfo(out cursorInfo);

                         if (cursorInfo.flags == CURSOR_SHOWING)
                         {
                              DrawIconEx(surface1.GetDC(false), cursorInfo.ptScreenPos.X, cursorInfo.ptScreenPos.Y, cursorInfo.hCursor, 0, 0, 0, IntPtr.Zero, DI_NORMAL | DI_DEFAULTSIZE);
                              surface1.ReleaseDC();
                         }
                    }

                    _device.ImmediateContext.CopyResource(_gdiImage, _destImage);

                    DataBox dataBox = _device.ImmediateContext.MapSubresource(_destImage, 0, MapMode.Read, SharpDX.Direct3D11.MapFlags.None);

                    using (System.Drawing.Bitmap bitmap = new System.Drawing.Bitmap(_textureDesc.Width, _textureDesc.Height, PixelFormat.Format32bppArgb))
                    {
                         System.Drawing.Rectangle boundsRect = new System.Drawing.Rectangle(0, 0, _textureDesc.Width, _textureDesc.Height);
                         BitmapData mapDest = bitmap.LockBits(boundsRect, ImageLockMode.WriteOnly, bitmap.PixelFormat);
                         IntPtr sourcePtr = dataBox.DataPointer;
                         IntPtr destPtr = mapDest.Scan0;
                         for (int y = 0; y < _textureDesc.Height; y++)
                         {
                              Utilities.CopyMemory(destPtr, sourcePtr, _textureDesc.Width * 4);
                              sourcePtr = IntPtr.Add(sourcePtr, dataBox.RowPitch);
                              destPtr = IntPtr.Add(destPtr, mapDest.Stride);
                         }
                         bitmap.UnlockBits(mapDest);
                         if (!String.IsNullOrEmpty(outputFile))
                         {
                              bitmap.Save(outputFile, ImageFormat.Png);
                         }
                    }
               }
              _device.ImmediateContext.UnmapSubresource(_destImage, 0);
          };
          desktopResource.Dispose();
          _duplication.ReleaseFrame(); // これを呼ばないと次で失敗する
     }

     public void Dispose()
     {
          _destImage.Dispose();
          _gdiImage.Dispose();
          _duplication.Dispose();
          _device.Dispose();
     }
}
"@

Add-Type -TypeDefinition $Source -Language CSharp -ReferencedAssemblies $Refs
$sc = New-Object -TypeName ScreenshotCapture

for($i=0; $i -lt 10; $i++){
Write-Host $i
$sc.CaptureScreen($PSScriptRoot + "\save" + $i + ".png")
Start-Sleep 1
}

$sc.Dispose()
$sc = $null


