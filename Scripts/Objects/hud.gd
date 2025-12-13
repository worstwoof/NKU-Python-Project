extends Control

@onready var health_bar = $HealthBar
@onready var speed_label = $SpeedLabel
# 获取新做的界面节点
@onready var game_over_panel = $GameOverPanel 
@onready var restart_button = $GameOverPanel/RestartButton
@onready var score_label = $ScoreLabel 

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
	
	# 确保一开始是隐藏的
	game_over_panel.visible = false

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

func _on_restart_pressed():
	# 1. 重置游戏数据 (调用 GameManager 的函数)
	GameManager.reset_game()
	
	# 2. 隐藏面板
	game_over_panel.visible = false
	
	# 3. 重新加载当前场景
	get_tree().reload_current_scene()
