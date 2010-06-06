@echo off
echo.
echo Deploying...
echo.

set Powershell=%WINDIR%\system32\WindowsPowerShell\v1.0\powershell.exe
%Powershell% -NoProfile -ExecutionPolicy Unrestricted -File Example.ps1

echo.
pause
