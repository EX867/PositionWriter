rem === change this ===
set PROJECTPATH="C:\Users\user\Documents\[Projects]\PositionWriter"

rem === pwrelease ===
cd "C:\Program Files (x86)\Resource Hacker"
ResourceHacker.exe -script %PROJECTPATH%\release\iconChanger\IconChanger%1_32.txt
ResourceHacker.exe -script %PROJECTPATH%\release\iconChanger\IconChanger%1_64.txt
cd %PROJECTPATH%\PW%1\application.windows64
del PW%1.exe
ren PW%1_res.exe PW%1.exe
cd data
del Colors.xml
del Shortcuts.xml
del Path.xml
cd %PROJECTPATH%\PW%1\application.windows32
del PW%1.exe
ren PW%1_res.exe PW%1.exe
cd data
del Colors.xml
del Shortcuts.xml
del Path.xml
cd %PROJECTPATH%\release
mkdir PositionWriter
cd PositionWriter
mkdir PositionWriter_32
mkdir PositionWriter_64
cd ..
cd ..
xcopy PW%1\application.windows32 release\PositionWriter\PositionWriter_32 /S
xcopy PW%1\application.windows64 release\PositionWriter\PositionWriter_64 /S
cd PW%1
rmdir application.windows32 /S
rmdir application.windows64 /S
cd "C:\Program Files (x86)\NSIS"
makensis /DVERSION=%1 %PROJECTPATH%\release\PWsetup.nsi
rmdir %PROJECTPATH%\release\PositionWriter /S
cd %PROJECTPATH%
set PROJECTPATH=
x
