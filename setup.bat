rem Set this to where you installed the libraries
cd "%~dp0..\dev\"
SET "devfolder=%cd%\"
SET "OCTAVE_HOME=%devfolder%octave"
SET "OPENCV_DIR=%devfolder%build\install"
SET "PATH=%PATH%;%devfolder%ninja;%OCTAVE_HOME%\bin;OPENCV_DIR"
set "PATH=%devfolder%build\install\x64\vc14\bin;%PATH%"
set "PATH=%devfolder%build\install\x64\mingw\bin;%PATH%"
rem cd "C:\Program Files (x86)\Microsoft Visual Studio 14.0\"
rem cd "%VS140COMNTOOLS%"
call "%VS140COMNTOOLS%VsDevCmd.bat"
rem cd %devfolder%
