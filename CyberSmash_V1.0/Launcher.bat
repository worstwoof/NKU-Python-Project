@echo off
title Cyber Smash Launcher

:: 1. 启动 AI 视觉引擎 (隐藏后台运行)
echo Starting AI Engine...
start "" "hand_controller\hand_controller.exe"

:: 2. 启动游戏
echo Starting Game...
:: start /wait 表示等游戏关闭后，脚本才继续往下走
start /wait "" "CyberSmash\CyberSmash.exe"

:: 3. 游戏关闭后的清理工作
:: 当玩家关掉游戏窗口后，强制关闭 AI 进程，防止它在后台一直占摄像头
taskkill /F /IM hand_controller.exe >nul 2>&1

exit