@echo off

@echo テスト用のファイルをコピー

@rem 壁紙のフォルダごとコピーする C:\Windows\Web\Wallpaper
xcopy /E /Y /D "C:\Windows\Web\Wallpaper" .\wallpapers\

exit /b 0

