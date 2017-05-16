@echo off
set "projectdir=%~dp0"
call setup.bat
cd %projectdir%
%comspec% /k
