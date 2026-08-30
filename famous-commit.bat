@echo off
setlocal enabledelayedexpansion

where gh >nul 2>&1
if errorlevel 1 (
    echo Error: GitHub CLI not found. Install from https://cli.github.com/
    pause
    exit /b 1
)

gh auth status >nul 2>&1
if errorlevel 1 (
    echo Error: Not logged in with gh. Run: gh auth login
    pause
    exit /b 1
)

echo.
echo Famous Commit Tool
echo.

set /p REPO_URL=Paste GitHub repo URL: 

set "REPO_URL=%REPO_URL:https://github.com/=%"
set "REPO_URL=%REPO_URL:http://github.com/=%"
set "REPO_URL=%REPO_URL:.git=%"
set "REPO_URL=%REPO_URL:/=\%"
for /f "tokens=1,2 delims=\" %%a in ("%REPO_URL%") do (
    set OWNER=%%a
    set REPO=%%b
)

if "%OWNER%"=="" (
    echo Could not parse repo URL.
    pause
    exit /b 1
)

set FULL_REPO=%OWNER%/%REPO%
echo Target: %FULL_REPO%
echo.

echo Select who to add as author (you can choose multiple):
echo.
echo  [1]  Linus Torvalds
echo  [2]  Guido van Rossum
echo  [3]  Yukihiro Matsumoto
echo  [4]  Sindre Sorhus
echo  [5]  Brendan Eich
echo  [6]  Ryan Dahl
echo  [7]  John Resig
echo  [8]  Addy Osmani
echo  [9]  Chris Lattner
echo [10]  Kent C. Dodds
echo [11]  Evan You
echo [12]  Rich Harris
echo  [0]  Cancel
echo.
echo Enter numbers separated by space or comma (example: 1 3 5 or 1,3,5)
echo.

set /p CHOICE=Choice: 

if "%CHOICE%"=="0" (
    echo Cancelled.
    pause
    exit /b 0
)

set "CHOICE=%CHOICE:,= %"

set TEMP_DIR=%TEMP%\famous-commit-%RANDOM%
mkdir "%TEMP_DIR%" >nul 2>&1

echo.
echo Cloning %FULL_REPO%...
gh repo clone %FULL_REPO% "%TEMP_DIR%" -- --depth 1 --quiet
if errorlevel 1 (
    echo Clone failed.
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
    pause
    exit /b 1
)

cd /d "%TEMP_DIR%"

for %%i in (%CHOICE%) do (
    set NUM=%%i

    if "!NUM!"=="1" (
        set AUTHOR_NAME=Linus Torvalds
        set AUTHOR_EMAIL=torvalds@linux-foundation.org
    ) else if "!NUM!"=="2" (
        set AUTHOR_NAME=Guido van Rossum
        set AUTHOR_EMAIL=guido@python.org
    ) else if "!NUM!"=="3" (
        set AUTHOR_NAME=Yukihiro Matsumoto
        set AUTHOR_EMAIL=matz@ruby.or.jp
    ) else if "!NUM!"=="4" (
        set AUTHOR_NAME=Sindre Sorhus
        set AUTHOR_EMAIL=sindresorhus@gmail.com
    ) else if "!NUM!"=="5" (
        set AUTHOR_NAME=Brendan Eich
        set AUTHOR_EMAIL=brendan@mozilla.org
    ) else if "!NUM!"=="6" (
        set AUTHOR_NAME=Ryan Dahl
        set AUTHOR_EMAIL=ry@tinyclouds.org
    ) else if "!NUM!"=="7" (
        set AUTHOR_NAME=John Resig
        set AUTHOR_EMAIL=jeresig@gmail.com
    ) else if "!NUM!"=="8" (
        set AUTHOR_NAME=Addy Osmani
        set AUTHOR_EMAIL=addyosmani@gmail.com
    ) else if "!NUM!"=="9" (
        set AUTHOR_NAME=Chris Lattner
        set AUTHOR_EMAIL=clattner@nondot.org
    ) else if "!NUM!"=="10" (
        set AUTHOR_NAME=Kent C. Dodds
        set AUTHOR_EMAIL=kent@doddsfamily.us
    ) else if "!NUM!"=="11" (
        set AUTHOR_NAME=Evan You
        set AUTHOR_EMAIL=yyx990803@gmail.com
    ) else if "!NUM!"=="12" (
        set AUTHOR_NAME=Rich Harris
        set AUTHOR_EMAIL=richard.harris@gmail.com
    ) else (
        echo Skipping invalid number: !NUM!
        set AUTHOR_NAME=
    )

    if defined AUTHOR_NAME (
        echo.
        echo Processing: !AUTHOR_NAME!

        set FILENAME=temp_!NUM!.txt
        echo Temporary line > "!FILENAME!"

        git -c user.name="!AUTHOR_NAME!" -c user.email="!AUTHOR_EMAIL!" add "!FILENAME!"
        git -c user.name="!AUTHOR_NAME!" -c user.email="!AUTHOR_EMAIL!" commit -m "Add temporary line"

        del "!FILENAME!" >nul 2>&1
        git -c user.name="!AUTHOR_NAME!" -c user.email="!AUTHOR_EMAIL!" add "!FILENAME!"
        git -c user.name="!AUTHOR_NAME!" -c user.email="!AUTHOR_EMAIL!" commit -m "Remove temporary line"
    )
)

echo.
echo Pushing all commits...
git push origin HEAD
if errorlevel 1 (
    echo Push failed. Do you have write access?
    cd /d "%USERPROFILE%"
    rmdir /s /q "%TEMP_DIR%" >nul 2>&1
    pause
    exit /b 1
)

echo.
echo Done!
echo.

cd /d "%USERPROFILE%"
rmdir /s /q "%TEMP_DIR%" >nul 2>&1
pause
endlocal
