extends Node3D

# --- 1. 原有的引用 ---
@export var obstacle_lock: PackedScene
@export var obstacle_spike: PackedScene
@export var obstacle_wall: PackedScene
@export var coin_blue: PackedScene
@export var coin_red: PackedScene
@export var capsule_heart: PackedScene
# --- 2. 新增胶囊引用 (记得在编辑器里把 tscn 拖进来) ---
@export var capsule_invincible: PackedScene # 青色无敌胶囊
@export var capsule_magnet: PackedScene     # 紫色磁铁胶囊

@export var lane_width: float = 3.5
@export var spawn_interval: float = 1.5

var timer: float = 0.0

func _process(delta):
	timer += delta
	# 随着游戏速度变快，生成间隔应该变短，不然障碍物会很稀疏
	# 这里做一个简单的动态调整：速度越快，间隔越小
	var current_interval = spawn_interval * (10.0 / GameManager.current_speed)
	
	if timer >= current_interval:
		spawn_random_object()
		timer = 0.0

# 定义一个变量记录上一次生成了什么
var last_spawn_type: String = ""


func spawn_random_object():
	var rand_val = randf()
	var instance = null
	var spawn_height = 1.5 # 默认高度是地面
	
	# --- 定义这一波生成的类型 ---
	var is_combo = false # 是否是组合生成 (地雷+金币)
	
	if rand_val < 0.30:
		# 30% 红锁 (必须躲，不能跳)
		instance = obstacle_lock.instantiate()
		
	elif rand_val < 0.40:
		# 20% 尖刺地雷 (建议跳跃)
		instance = obstacle_spike.instantiate()
		is_combo = true # 标记为组合，准备生成头顶金币

	elif rand_val < 0.50:
		instance = obstacle_wall.instantiate()
		
	elif rand_val < 0.80:
		# 30% 蓝币 (普通)
		instance = coin_blue.instantiate()
		# 【新玩法】偶尔让蓝币出现在空中，诱导玩家乱跳
		if randf() > 0.7: spawn_height = 3
		
	elif rand_val < 0.95:
		# 15% 红币 (空中飞弹！)
		instance = coin_red.instantiate()
		spawn_height = 3 # 让它浮在半空，玩家必须跳起来吃
		
	else:
		# 5% 道具
		# 道具通常放在地面比较稳妥，或者低空
		rand_val = randf()
		if rand_val < 0.2:
			instance = capsule_invincible.instantiate()
		elif rand_val < 0.4:
			instance = capsule_magnet.instantiate()
		else:
			instance = capsule_heart.instantiate()

	# --- 1. 生成主体 ---
	if instance:
		add_child(instance)
		var lane_index = randi_range(-1, 1)
		# 应用高度 spawn_height
		instance.position = Vector3(lane_index * lane_width, spawn_height, -60)
		
		# --- 2. 处理组合生成 (地雷头顶的币) ---
		if is_combo:
			# 实例化一个额外的蓝币
			var bonus_coin = coin_blue.instantiate()
			add_child(bonus_coin)
			# 位置：和地雷在同一条道，但是在空中 (Y=2.5)
			# Z轴稍微错开一点点也可以，或者完全重合
			bonus_coin.position = Vector3(lane_index * lane_width, 3, -20)

#func spawn_random_object():
	#var instance
	#var rand_val = randf()
	#var current_type = ""
	#
	#if rand_val < 0.50:
		#instance = obstacle_lock.instantiate()
		#current_type = "obstacle"
	#elif rand_val < 0.90:
		## 把金币概率合并，这里简化处理
		#if randf() > 0.5:
			#instance = coin_blue.instantiate()
		#else:
			#instance = coin_red.instantiate()
		#current_type = "coin"
	#else:
		## 10% 概率出超级道具
		#rand_val = randf()
		#if rand_val < 0.2:
			#instance = capsule_invincible.instantiate()
		#elif rand_val < 0.4:
			#instance = capsule_magnet.instantiate()
		#else:
			#instance = capsule_heart.instantiate()
		#current_type = "capsule"
	#
	#add_child(instance)
	#
	## --- 智能跑道选择 ---
	#var lane_index = randi_range(-1, 1)
	#
	## 如果是超级胶囊，我们故意让它生成在旁边，而不是正中间(0)，增加一点点操作门槛
	#if current_type == "capsule":
		#if randf() > 0.5: lane_index = -1
		#else: lane_index = 1
		#
	#instance.position = Vector3(lane_index * lane_width, 0, -20)
