extends Control

@onready var health_bar = $HealthBar
@onready var speed_label = $SpeedLabel
# 获取新做的界面节点
@onready var game_over_panel = $GameOverPanel 
@onready var restart_button = $GameOverPanel/RestartButton
@onready var score_label = $ScoreLabel 
@onready var distance_label = $DistanceLabel
@onready var pause_panel = $PausePanel 
@onready var resume_button = $PausePanel/ResumeButton
@onready var quit_button = $PausePanel/QuitButton # 如果你有这个按钮

var is_game_over = false # 用来防止死亡后还能按出暂停菜单
func update_ui(hp, speed, score):
	health_bar.value = hp
	speed_label.text = "DATA FLOW: %.1f MB/s" % speed
	_on_score_changed(score)

# 信号回调函数
func _on_hp_changed(new_hp):
	health_bar.value = new_hp

func _on_speed_changed(new_speed):
	speed_label.text = "DATA FLOW: %.1f MB/s" % new_speed

func _ready():
	# 初始化UI
	update_ui(GameManager.current_hp, GameManager.current_speed, GameManager.score)
	
	# 连接信号
	GameManager.connect("hp_changed", Callable(self, "_on_hp_changed"))
	GameManager.connect("speed_changed", Callable(self, "_on_speed_changed"))
	GameManager.connect("score_changed", Callable(self, "_on_score_changed"))
	GameManager.connect("game_over", Callable(self, "_on_game_over")) # 新增
	
	# 连接按钮点击信号
	restart_button.pressed.connect(self._on_restart_pressed)
	
# --- 新增：连接暂停菜单按钮信号 ---
	resume_button.pressed.connect(self._on_resume_pressed)
	quit_button.pressed.connect(self._on_quit_pressed)

	# 确保面板隐藏
	game_over_panel.visible = false
	pause_panel.visible = false
# --- 新增：监听按键输入 (ESC 键) ---
func _input(event):
	# 如果按下了 UI Cancel (默认是 ESC)，且游戏没有结束
	if event.is_action_pressed("ui_cancel") and not is_game_over:
		toggle_pause()

# --- 新增：切换暂停状态的函数 ---
func toggle_pause():
	var tree = get_tree()
	tree.paused = not tree.paused # 切换暂停状态
	
	if tree.paused:
		pause_panel.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # 显示鼠标
	else:
		pause_panel.visible = false
		# 如果你的游戏需要隐藏鼠标，可以在这里设置 CAPTURED
		# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)	

func _on_resume_pressed():
	toggle_pause() # 再次调用以取消暂停

func _on_quit_pressed():
	# 恢复时间流动，否则下一局可能卡住
	get_tree().paused = false 
	# 切换回主菜单场景 (需要你先创建主菜单场景，见第三步)
	# get_tree().change_scene_to_file("res://Scenes/Levels/MainMenu.tscn")
	# 暂时先用退出游戏代替：
	get_tree().quit()
func _process(delta):
	# 我们不需要专门写信号，因为距离每一帧都在变
	# 直接在这里读取 GameManager 的数据最流畅
	
	# floor() 是向下取整，把 10.53米 变成 10米
	var dist_int = floor(GameManager.total_distance)
	
	# 格式化显示： "DIST: 0123 m"
	distance_label.text = "DIST: %04d m" % dist_int
func _on_score_changed(new_score):
	# 格式化字符串：
	# "SCORE: %06d" 的意思是：显示整数，如果不足6位，前面补0
	# 例如 50分 -> 显示 "000050"
	# 这种等宽数字看起来非常有计算机终端的感觉
	score_label.text = "SCORE: %06d" % new_score
	
	## --- 4. (可选) 增加一点“打击感”动画 ---
	## 每次得分，数字会瞬间变大然后弹回去
	#var tween = create_tween()
	#score_label.scale = Vector3(1.2, 1.2, 1.2) # 变大
	## 0.1秒内变回原样
	#tween.tween_property(score_label, "scale", Vector3(1.0, 1.0, 1.0), 0.1)

func _on_game_over():
	# 显示失败界面
	game_over_panel.visible = true
	# 显示鼠标光标 (如果不显示玩家没法点按钮)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AudioStreamPlayer.play()

func _on_restart_pressed():
	# 1. 重置游戏数据 (调用 GameManager 的函数)
	GameManager.reset_game()
	
	# 2. 隐藏面板
	game_over_panel.visible = false
	
	# 3. 重新加载当前场景
	get_tree().reload_current_scene()
