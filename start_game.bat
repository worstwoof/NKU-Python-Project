@echo off
title Cyber Smash Launcher
color 0A

echo ==========================================
echo       CYBER SMASH: DATA DESTRUCTION
echo           System Initializing...
echo ==========================================

:: ================= 配置区域 =================

:: 1. Godot 路径 (这是外部软件，通常保持绝对路径)
::    如果你想让这里也变成相对路径，你需要把 godot.exe 复制到项目里
set "GODOT_PATH=F:\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe"

:: 2. Python 脚本路径 (已改为相对路径！)
::    %~dp0 代表 "当前bat文件所在的目录"，会自动拼接后面的路径
set "PYTHON_SCRIPT=%~dp0Python_Controller\hand_controller.py"

:: 3. Anaconda 环境设置
::    注意：这是为了让脚本能找到 conda，通常需要绝对路径
set "CONDA_ACTIVATE=F:\Anaconda\Scripts\activate.bat"
set "ENV_NAME=my_d2l"

:: ================= 启动逻辑 =================

echo [1/2] Starting AI Vision System (Python)...

:: 检查 Python 脚本是否存在，防止路径错误
if not exist "%PYTHON_SCRIPT%" (
    echo [ERROR] Can not find python script:
    echo %PYTHON_SCRIPT%
    pause
    exit
)

:: 使用 call 调用 conda 环境并运行脚本
start "Cyber Eye AI" cmd /k "call "%CONDA_ACTIVATE%" %ENV_NAME% && python "%PYTHON_SCRIPT%""

echo [2/2] Starting Game Engine (Godot)...

:: 启动 Godot，--path "%~dp0." 告诉 Godot 项目就在当前目录下
start "" "%GODOT_PATH%" --path "%~dp0." 

echo.
echo >> System Ready. Good Luck, Hacker.
echo.

timeout /t 3 >nul
exit