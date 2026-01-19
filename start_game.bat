@echo off
title Cyber Smash Launcher
color 0A

echo ==========================================
echo       CYBER SMASH: DATA DESTRUCTION
echo          System Initializing...
echo ==========================================


set "GODOT_PATH=F:\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe"


set "PYTHON_SCRIPT=Python_Controller\hand_controller.py"



echo [1/2] Starting AI Vision System (Python)...

start "Cyber Eye AI" cmd /k "F:/Anaconda/Scripts/activate & conda activate my_d2l & python %PYTHON_SCRIPT%"

echo [2/2] Starting Game Engine (Godot)...

start "" "%GODOT_PATH%" --path "%~dp0." 

echo.
echo >> System Ready. Good Luck, Hacker.
echo.


timeout /t 3 >nul
exit