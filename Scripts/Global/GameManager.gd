extends Node

# --- 信号：通知UI更新 ---
signal hp_changed(current_hp)
signal speed_changed(current_speed)
signal game_over
# --- 新增配置 ---
@export var acceleration: float = 0.5   # 加速度：每秒增加 0.5 的速度
@export var max_game_speed: float = 100 # 速度上限：防止快到人类无法反应
# --- 全局变量 ---
@export var max_hp: int = 3
var current_hp: int = 3

@export var base_speed: float = 15.0
var current_speed: float = 10.0 # 这是游戏的主节奏速度
var total_distance: float = 0.0 # 记录跑了多少米
func _ready():
	# 初始化
	current_hp = max_hp
	current_speed = base_speed

var score: int = 0
signal score_changed(new_score)
func _process(delta):
	# 如果游戏没有暂停，且速度还没达到上限
	total_distance += current_speed * delta
	if not get_tree().paused and current_speed < max_game_speed:
		
		# 1. 随着时间平滑加速
		current_speed += acceleration * delta
		
		# 2. 通知 UI 更新 (显示 DATA FLOW 速度)
		# 为了优化性能，也可以不每一帧都发信号，但对于 demo 来说没问题
		emit_signal("speed_changed", current_speed)
func add_score(amount: int):
	score += amount
	emit_signal("score_changed", score)
	# print("当前分数: ", score)

func change_hp(amount: int):
	current_hp += amount
	if current_hp > max_hp:
		current_hp = max_hp
	
	emit_signal("hp_changed", current_hp)
	
	# --- 死亡逻辑修改 ---
	if current_hp <= 0:
		emit_signal("game_over")
		print("SYSTEM FAILURE!")
		# 【关键】暂停游戏！所有 physics_process 都会停止
		get_tree().paused = true 

# --- 新增：重置游戏函数 ---
func reset_game():
	# 1. 恢复数据
	current_hp = max_hp
	current_speed = base_speed
	total_distance = 0.0
	# 2. 恢复游戏运行状态 (取消暂停)
	get_tree().paused = false
	
	# 3. 通知UI更新回满血状态 (可选，防止UI闪烁)
	emit_signal("hp_changed", current_hp)
	emit_signal("speed_changed", current_speed)
	score = 0
	emit_signal("score_changed", score)

# --- 功能函数：修改速度 ---
func change_speed(amount: float):
	current_speed += amount
	# 设置一个最小速度，防止倒着跑
	if current_speed < 5.0:
		current_speed = 5.0
		
	emit_signal("speed_changed", current_speed)
	print("当前速度: ", current_speed)

# 定义一个新信号，带着一个布尔值参数
signal invincibility_changed(is_active) 

var is_invincible: bool = false

func activate_invincibility(duration: float):
	is_invincible = true
	# 发送信号：无敌开始了！(true)
	emit_signal("invincibility_changed", true)
	print("护盾开启")
	
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	
	is_invincible = false
	# 发送信号：无敌结束了！(false)
	emit_signal("invincibility_changed", false)
	print("护盾关闭")

signal magnet_state_changed(is_active)

func activate_magnet(duration: float):
	emit_signal("magnet_state_changed", true)
	print("磁场启动！")
	
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	
	emit_signal("magnet_state_changed", false)
	print("磁场结束")
