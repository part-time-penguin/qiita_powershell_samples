@echo off

@rem �C���X�g�[���p�X�ɍ��킹�ĕύX���Ă�������
@set zip_app_path=C:\Program Files\7-Zip\7z.exe

if not exist "%zip_app_path%" (
    echo %zip_app_path% ��7zip���C���X�g�[������Ă��܂���B    
    exit /b 1
)

@echo 7zip�̃p�X=%zip_app_path% 

@echo 7z�ɕ����I�v�V�������w�肵�Ď��s -v1m��1MB�ŕ��� -v1g��1GB�ŕ���

"%zip_app_path%" a -v1m wallpapers.zip .\wallpapers


exit /b 0

