@echo off

@rem インストールパスに合わせて変更してください
@set zip_app_path=C:\Program Files\7-Zip\7z.exe

if not exist "%zip_app_path%" (
    echo %zip_app_path% に7zipがインストールされていません。    
    exit /b 1
)

@echo 7zipのパス=%zip_app_path% 

@echo 7zに分割オプションを指定して実行 -v1m→1MBで分割 -v1g→1GBで分割

"%zip_app_path%" a -v1m wallpapers.zip .\wallpapers


exit /b 0

