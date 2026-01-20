extends Control

# --- 【必须配置】在这里填入你的主菜单场景路径 ---
# 记得在右侧检查器里把 MainMenu.tscn 拖进来！
@export_file("*.tscn") var main_menu_path: String = "res://addons/MainMenu/MainMenu.tscn" 

@onready var health_bar = $HealthBar
@onready var speed_label = $SpeedLabel

# 游戏结束面板组件
@onready var game_over_panel = $GameOverPanel 
# 我们复用之前的 RestartButton，现在它就是“返回菜单”按钮
@onready var back_to_menu_button = $GameOverPanel/RestartButton 

@onready var score_label = $ScoreLabel 
@onready var distance_label = $DistanceLabel

# 暂停面板组件
@onready var pause_panel = $PausePanel 
@onready var resume_button = $PausePanel/ResumeButton
@onready var quit_button = $PausePanel/QuitButton 

var is_game_over = false 

func _ready():
	# 初始化UI
	update_ui(GameManager.current_hp, GameManager.current_speed, GameManager.score)
	
	GameManager.connect("hp_changed", Callable(self, "_on_hp_changed"))
	GameManager.connect("speed_changed", Callable(self, "_on_speed_changed"))
	GameManager.connect("score_changed", Callable(self, "_on_score_changed"))
	GameManager.connect("game_over", Callable(self, "_on_game_over"))
	
	# --- 连接信号 ---
	# 这里把原来的 Restart 按钮，连接到了新的“返回菜单”函数上
	back_to_menu_button.pressed.connect(self._on_return_to_menu_pressed)
	
	resume_button.pressed.connect(self._on_resume_pressed)
	# 暂停界面的退出按钮也一样返回主菜单
	quit_button.pressed.connect(self._on_return_to_menu_pressed)

	game_over_panel.visible = false
	pause_panel.visible = false

# --- 通用的“返回主菜单”逻辑 ---
func _on_return_to_menu_pressed():
	print("正在返回主菜单...")
	
	# 1. 这一步最重要！必须先取消暂停，否则主菜单会卡死动不了
	get_tree().paused = false 
	
	# 2. 清理上一局的数据
	GameManager.reset_game()
	
	# 3. 切换场景
	if main_menu_path != "":
		get_tree().change_scene_to_file("res://Scenes/Levels/Black.tscn")
	else:
		print("❌ 错误：你忘了在检查器里设置 Main Menu Path！")
		get_tree().quit() # 如果没设路径，就直接退出游戏

# --- 其他不需要改动的函数 ---
func update_ui(hp, speed, score):
	health_bar.value = hp
	speed_label.text = "DATA FLOW: %.1f MB/s" % speed
	_on_score_changed(score)

func _on_hp_changed(new_hp): health_bar.value = new_hp
func _on_speed_changed(new_speed): speed_label.text = "DATA FLOW: %.1f MB/s" % new_speed
func _on_score_changed(new_score): score_label.text = "SCORE: %06d" % new_score
func _process(delta): distance_label.text = "DIST: %04d m" % floor(GameManager.total_distance)

func _input(event):
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		toggle_pause()

func toggle_pause():
	var tree = get_tree()
	tree.paused = not tree.paused 
	pause_panel.visible = tree.paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if tree.paused else Input.MOUSE_MODE_VISIBLE) 

func _on_resume_pressed(): toggle_pause() 

# --- 在脚本最上面添加变量 ---
@onready var fade_overlay = $FadeOverlay # 记得确保节点名字一致

# ... 其他代码 ...

# --- 修改后的游戏结束逻辑 ---
func _on_game_over():
	print("🔴 游戏结束函数触发了！")
	is_game_over = true
	
	# 1. 强行显示遮罩
	fade_overlay.visible = true
	# 确保遮罩完全透明作为起点
	fade_overlay.modulate.a = 0.0
	
	# 2. 暂停游戏世界 (防止飞船继续撞墙、刷日志)
	# 注意：这一步会导致所有节点停止更新，除非我们设置了 Process Mode
	get_tree().paused = true
	
	# 3. 创建动画
	var tween = create_tween()
	# 关键：告诉动画在“游戏暂停”时也要继续播放！
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	# 4. 执行变黑 (2秒)
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.0)
	
	# 5. 等待动画结束
	await tween.finished
	
	# 6. 显示菜单
	game_over_panel.visible = true
	
	# 7. 解锁鼠标
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
