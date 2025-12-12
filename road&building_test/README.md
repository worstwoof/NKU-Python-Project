# 🦖 Cyber Smash: Data Destruction (赛博黑客：数据大破坏)

![Godot Engine](https://img.shields.io/badge/Godot-v4.5+-blue.svg) ![Python](https://img.shields.io/badge/Python-3.x-yellow.svg) ![MediaPipe](https://img.shields.io/badge/MediaPipe-0.10+-teal.svg) ![Status](https://img.shields.io/badge/Status-In%20Development-orange)

> **"操控赛博怪兽，粉碎防火墙，成为数据洪流中的破坏王！"**
> 
> 这是一个基于 **Godot 4** 引擎开发，结合 **Python MediaPipe** 体感控制的 3D 无尽跑酷游戏。玩家通过摄像头控制一只体素风格的怪兽，在赛博朋克风格的电子高速公路上狂奔。

---

## 🎮 核心玩法 (Features)

* **👾 赛博怪兽 (Cyber Kaiju):** 扮演由故障数据组成的体素怪兽。
* **📸 体感操控 (Motion Control):**
    * **头部倾斜:** 控制左右变道。
    * **挥动拳头:** 击碎前方的红色防火墙 (Firewall)。
    * **张开手掌:** 破解加密门。
* **💥 物理破坏:** 利用 Godot 物理引擎实现的积木坍塌效果，极致解压。
* **🌃 赛博视效:** 独特的 MagicaVoxel 低模风格 + Godot WorldEnvironment 辉光特效。

---

## 📂 项目目录结构 (Project Structure)

为防止多人协作冲突，请严格遵守以下目录规范：

```text
CyberSmash_Project/
├── Assets/                 # 🎨 美术资源仓库
│   ├── Models/             # MagicaVoxel 导出的 .obj/.gltf
│   │   ├── Character/      # 金宇辰 怪兽模型
│   │   ├── Environment/    # 黄子豪/刘珂 路块、大楼模型
│   │   └── Props/          # 蔡子涵 障碍物、金币
│   ├── Audio/              # 🎵 音效与 BGM
│   └── Textures/           # 🖼️ 贴图文件
├── Scenes/                 # 🎬 Godot 场景文件 (.tscn)
│   ├── Levels/             # 关卡主场景 (Main.tscn)
│   ├── Prefabs/            # 预制件 (独立开发的零件)
│   │   ├── Player.tscn     # 怪兽
│   │   ├── RoadChunk.tscn  # 路块
│   │   └── Obstacles/      # 各种障碍
│   └── UI/                 # 界面场景
├── Scripts/                # 📝 Godot 脚本 (.gd)
│   ├── Global/             # 全局单例 (GameManager)
│   ├── Player/             # 角色控制逻辑
│   └── Level/              # 地图生成逻辑
├── Python_Controller/      # 🐍 MediaPipe 控制器 (独立运行)
│   ├── main.py             # Python 入口
│   └── requirements.txt    # 依赖库
└── project.godot           # 项目配置文件
````

-----

## 🚀 快速开始 (Getting Started)

### 1\. 游戏端 (Godot)

1.  下载并打开 **Godot Engine 4.x**。
2.  点击 `导入 (Import)`，选择本项目的根文件夹。
3.  运行 `Main.tscn` 场景。
      * *注意：此时游戏会监听 UDP 端口 (默认 5005) 等待指令。*

### 2\. 控制端 (Python)

你需要一个摄像头来游玩本项目。

1.  安装依赖：
    ```bash
    pip install mediapipe opencv-python
    ```
2.  运行控制脚本：
    ```bash
    cd Python_Controller
    python main.py
    ```
3.  对准摄像头，开始你的表演！

-----

## 👥 团队分工 (The Team)

| 成员 | 角色代号 | 职责范围 | 关键产出 |
| :--- | :--- | :--- | :--- |
| **成员 黄子豪** | 🛣️ 赛道基建师 | **场景搭建** | 网格路面、无限生成逻辑、碰撞边界 |
| **成员 金宇辰** | 🦖 怪兽生物师 | **主角制作** | 体素怪兽建模、Mixamo 动作绑定、状态机 |
| **成员 蔡子涵** | 🧱 障碍交互师 | **关卡设计** | 可破坏墙体、金字塔陷阱、金币、物理碰撞 |
| **成员 刘珂** | 🏙️ 城市景观师 | **氛围营造** | 赛博摩天大楼、空中拱门、辉光特效 (Shader) |

-----

## ⚠️ 协作铁律 (Development Rules)

1.  **互不侵犯：** 严禁修改不属于你职责范围内的 `.tscn` 文件。
2.  **资源归位：** 所有模型必须放在 `Assets` 对应的子文件夹内，严禁扔在根目录。
3.  **主场景保护：** `Main.tscn` 由**队长**统一维护。成员开发时请使用 `Test_Level.tscn` 进行测试。
4.  **提交规范：** 每天收工前，请确保代码无报错后再 Push 到仓库。

-----

## 🎨 美术规范 (Art Style)

  * **风格：** Voxel Cyberpunk (体素赛博朋克)
  * **工具：** MagicaVoxel
  * **标准色板：**
      * ⚫ **背景/建筑主体:** 纯黑 (\#000000)
      * 🔵 **主角/友方:** 青色 (\#00FFFF) [高发光]
      * 🔴 **敌人/障碍:** 洋红 (\#FF00FF) [高发光]
      * 🟡 **奖励:** 亮黄 (\#FFFF00) [高发光]



```
```
