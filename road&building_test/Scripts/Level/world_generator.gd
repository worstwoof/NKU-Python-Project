extends Node3D

# --- 1. 资源配置区 (把做好的三个场景拖进来) ---
@export_group("地图资源")
@export var road_straight: PackedScene      # 拖入 RoadChunk.tscn (直道)
@export var road_break_start: PackedScene   # 拖入 RoadChunk_BreakStart.tscn (断头)
@export var road_break_end: PackedScene     # 拖入 RoadChunk_BreakEnd.tscn (断尾/跳台)

# --- 2. 游戏参数区 ---
@export_group("游戏设置")
@export var scroll_speed: float = 20.0      # 移动速度
@export var chunk_count: int = 5            # 视野内保持几个路块 (建议5-7个)

# --- 3. 内部变量区 ---
var road_chunks: Array = []   # 存放当前场景里的路块
var chunk_length: float = 30.0 # 路块长度 (必须和模型一致!)

# --- 4. 随机生成逻辑变量 ---
var next_must_be_end: bool = false # 标记：下一个是不是必须生成“断桥尾”？
var safe_zone_count: int = 3       # 保护期：刚生成完断桥后，强制生成几块直道？

func _ready():
	randomize() # 让随机数每次都不一样
	
	# 游戏刚开始，先铺满直道 (给玩家准备时间)
	for i in range(chunk_count):
		spawn_chunk(road_straight, -i * chunk_length)

func _process(delta):
	# --- A. 让所有路块动起来 ---
	for chunk in road_chunks:
		chunk.position.z += scroll_speed * delta
	
	# --- B. 检查并生成新路 ---
	# 我们只检查最靠近玩家的那一块 (数组第0个)
	if road_chunks.size() > 0:
		var first_chunk = road_chunks[0]
		
		# 如果这一块跑到了身后 (Z > 30)，就把它销毁，并在远处生成新的
		if first_chunk.position.z > chunk_length:
			
			# 1. 在数组里移除它
			road_chunks.pop_front()
			
			# 2. 在场景里删除它 (因为它再也用不到了)
			first_chunk.queue_free()
			
			# 3. 在最远处生成一个新的
			spawn_next_random_chunk()

# --- 核心函数：决定下一块生成什么 ---
func spawn_next_random_chunk():
	# 找到当前队伍里最后一块的位置
	var last_chunk = road_chunks.back()
	var new_z_pos = last_chunk.position.z - chunk_length
	
	var scene_to_spawn = road_straight # 默认生成直道
	
	# --- 🧠 智能生成逻辑 ---
	
	if next_must_be_end:
		# 情况1：上一块是断桥头，这一块必须是断桥尾！(强制配对)
		scene_to_spawn = road_break_end
		next_must_be_end = false # 配对完成，重置标记
		safe_zone_count = 3      # 刚跳过去，给玩家 3 块直道休息一下
		print("生成：断桥尾 (跳台)")
		
	elif safe_zone_count > 0:
		# 情况2：处于“保护期”，强制生成直道
		scene_to_spawn = road_straight
		safe_zone_count -= 1     # 保护次数减 1
		# print("生成：安全直道")
		
	else:
		# 情况3：可以随机了！
		var random_val = randf() # 生成 0.0 到 1.0 的随机数
		
		if random_val < 0.3: # 30% 的概率生成断桥
			scene_to_spawn = road_break_start
			next_must_be_end = true # 标记：下一块记得给我补个屁股！
			print("生成：断桥头 (小心！)")
		else:
			scene_to_spawn = road_straight
			# print("生成：随机直道")
	
	# --- 执行生成 ---
	spawn_chunk(scene_to_spawn, new_z_pos)

# --- 基础函数：生成具体的路块 ---
func spawn_chunk(scene_res, z_pos):
	if scene_res == null:
		print("❌ 错误：有路块场景没拖进去！检查右侧 Inspector")
		return
		
	var new_obj = scene_res.instantiate()
	add_child(new_obj)
	new_obj.position.z = z_pos
	road_chunks.append(new_obj)
