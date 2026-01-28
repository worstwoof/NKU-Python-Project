# Cyber Smash (赛博黑客) - 体感跑酷游戏

![Godot Engine](https://img.shields.io/badge/Godot-v4.5+-blue.svg) ![Python](https://img.shields.io/badge/Python-3.x-yellow.svg) ![MediaPipe](https://img.shields.io/badge/MediaPipe-0.10+-teal.svg)

这是一个基于 **Godot 4** 引擎开发，并结合 **Python MediaPipe** 实现体感控制的 3D 无尽跑酷游戏。玩家通过摄像头和手势，控制一只赛博朋克风格的怪兽，在充满霓虹灯效的数字高速公路上躲避障碍、摧毁敌人、挑战高分。

---

## 1. ✨ 核心功能

*   **✋ AI 手势控制:** 无需手柄或键盘！项目通过 Python、OpenCV 和 MediaPipe 实时捕捉摄像头前的手部动作，实现真正的体感交互。
    *   **左右移动:** 手在画面中的水平位置决定角色移动方向。
    *   **跳跃:** 快速向上挥手。
    *   **攻击:** 握拳。
*   **💥 动态跑酷世界:**
    *   **程序化无限关卡:** 道路和障碍物自动生成，每一次奔跑都是新的挑战。
    *   **速度递增:** 游戏速度会随时间不断加快，考验你的反应极限。
    *   **可破坏的障碍:** 部分障碍物需要通过“握拳”手势来击碎。
*   **🎁 丰富的游戏元素:**
    *   **道具系统:** 包含“无敌护盾”和“金币磁铁”等多种增强道具。
    *   **得分与生命系统:** 完整的游戏循环，包含得分统计和生命值管理。
*   **🎮 一键启动:** 项目提供了 `Launcher.bat` 脚本，可以一键启动手势控制器和游戏主程序，并能在游戏结束后自动清理进程，极大地方便了普通用户。
*   **🌐 项目宣传网站:** 项目包含一个使用 HTML/CSS 制作的精美静态网页，用于展示游戏特色、开发团队和下载指南。

---

## 2. 🛠️ 技术栈

*   **游戏引擎:** **Godot Engine 4.5+**
*   **游戏逻辑:** **GDScript**
*   **体感控制:** **Python 3**
    *   **`opencv-python`**: 用于摄像头视频流处理。
    *   **`mediapipe`**: 用于高性能的手部关键点检测和姿态识别。
*   **通信:** Python 控制器通过 **UDP** 协议将指令发送给 Godot 游戏。
*   **前端展示:** **HTML5 / CSS3**

---

## 3. 📂 目录结构

```
D:\DESKTOP\NKU-PYTHON-PROJECT
│
├── CyberSmash_V1.0/     # 存放【已打包的可执行版本】，适合直接游玩
│   ├── Launcher.bat         # ✅ 推荐！一键启动器
│   ├── CyberSmash/          # Godot 游戏程序
│   └── hand_controller/     # Python 控制器程序
│
├── 前端/                  # 存放【项目宣传网页】的源代码
│   ├── index.html
│   └── style.css
│
├── 项目源代码/            # 存放【完整的开发源文件】，适合开发者
│   ├── project.godot        # Godot 项目主文件
│   ├── Assets/              # 美术、音频等资源
│   ├── Scenes/              # Godot 场景 (.tscn)
│   ├── Scripts/             # GDScript 脚本 (.gd)
│   └── Python_Controller/   # Python 控制器源代码 (.py)
│
├── info.txt               # (本文) 由 AI 生成的详细项目介绍
└── README.md              # (本文) 由 AI 生成的项目 README
```

---

## 4. 🚀 如何开始

### 快速游玩 (面向玩家)

1.  进入 `CyberSmash_V1.0` 文件夹。
2.  确保你的电脑已连接并允许使用摄像头。
3.  直接双击运行 `Launcher.bat` 文件，它会自动为你准备好一切。
4.  开始游戏，并根据屏幕上的摄像头预览调整你的手势！

### 从源码运行 (面向开发者)

1.  **启动游戏端:**
    *   下载并安装 **Godot Engine 4.x**。
    *   在 Godot 中，选择“导入”，然后选择 `项目源代码` 文件夹。
    *   打开项目后，可以运行主场景 `main.tscn` 或 `MainMenu.tscn`。
2.  **启动控制端:**
    *   确保你的电脑安装了 Python 3。
    *   安装必要的库：`pip install opencv-python mediapipe`
    *   进入 `项目源代码/Python_Controller/` 目录。
    *   运行脚本: `python hand_controller.py`。
3.  **开始游戏:**
    *   **务必先启动 Python 控制器**，再从 Godot 编辑器中启动游戏。