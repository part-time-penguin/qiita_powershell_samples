
@echo off
set ARGS_PARAM=

:loop
if "%~f1" == "" goto end
set ARGS_PARAM=%ARGS_PARAM% '%~f1'
shift
goto loop

:end
powershell -NoProfile -ExecutionPolicy Unrestricted ".\sendto.ps1" %ARGS_PARAM%
