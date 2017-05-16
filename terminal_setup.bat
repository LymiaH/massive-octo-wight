@echo off
set "projectdir=%~dp0"
call ..\dev\setup.bat
cd %projectdir%
%comspec% /k
