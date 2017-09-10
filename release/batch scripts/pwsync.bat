rem === change this ===
set PROJECTPATH="C:\Users\user\Documents\[Projects]\PositionWriter"

rem === gitpull ===
if exist %PROJECTPATH% (
	cd %PROJECTPATH%
	echo.
	echo "success!"
	git pull
) else (
	echo.
	echo "failed! - nonexisting directory"
	echo %PROJECTPATH%
)
cd %PROJECTPATH%
set PROJECTPATH=
x
