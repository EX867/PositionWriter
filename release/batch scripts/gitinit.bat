set argC=0
for %%x in (%*) do Set /A argC+=1
if %argC%==2 (
	if exist %~1 (
		cd %1
		git init
		git add .
		git commit -m "move to git"
		git remote add origin %~2
		git push -u origin master
	) else (
		echo.
		echo "failed! - nonexisting directory"
		echo %~1
	)
) else (
	echo.
	echo "failed! - incorrect arguments count
	echo %~1
)