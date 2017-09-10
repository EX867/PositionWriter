rem === change this ===
set PROJECTPATH="C:\Users\user\Documents\[Projects]\PositionWriter\"

rem === gitpush ===
set argC=0
for %%x in (%*) do Set /A argC+=1
if %argC%==1 (
	if exist %PROJECTPATH% (
		cd %PROJECTPATH%
		echo.
		echo "success!"
		git add .
		git commit -m "%~1"
		git push
	) else (
		echo.
		echo "failed! - nonexisting directory"
		echo %PROJECTPATH%
	)
) else (
	echo.
	echo "failed! - incorrect arguments count
	echo %PROJECTPATH%
)
cd %PROJECTPATH%
set PROJECTPATH=
x
