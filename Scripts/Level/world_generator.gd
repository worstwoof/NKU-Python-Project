extends Node3D

# --- 1. 配置参数区 ---
@export_group("路块设置")
@export var road_chunk_scene: PackedScene      # 普通路面
@export var road_chunk_gap: PackedScene        # 断桥起点
@export var road_chunk_gap_head: PackedScene   # 断桥终点

@export var chunk_count: int = 7           # 建议稍微多一点，防止远端穿帮
@export var chunk_length: float = 30.0     # 路块长度

# --- 2. 内部变量 ---
var road_chunks: Array = [] 
var next_must_be_head: bool = false 

func _ready():
	spawn_initial_road()

func _process(delta):
	move_road(delta)

func spawn_initial_road():
	if not road_chunk_scene or not road_chunk_gap or not road_chunk_gap_head:
		print("错误：请配置路块场景！")
		return

	# 初始生成的全是普通路面
	for i in range(chunk_count):
		spawn_new_chunk(0 - (i * chunk_length), road_chunk_scene)

# --- 修改 A：生成时打上标签 ---
func spawn_new_chunk(z_pos: float, scene_to_spawn: PackedScene):
	var new_chunk = scene_to_spawn.instantiate()
	
	# 【关键】给这个节点贴个标签，记录它是哪种类型的场景
	# 这样我们后面才能判断能不能复用它
	new_chunk.set_meta("source_scene", scene_to_spawn)
	
	add_child(new_chunk)
	new_chunk.position.z = z_pos
	road_chunks.append(new_chunk)
	return new_chunk

# --- 修改 B：移动逻辑 ---
func move_road(delta):
	# 倒序遍历
	for i in range(road_chunks.size() - 1, -1, -1):
		var chunk = road_chunks[i]
		
		# 1. 移动
		chunk.position.z += GameManager.current_speed * delta
		
		# 2. 检查是否跑出视野
		if chunk.position.z > chunk_length:
			
			# 计算新位置
			var furthest_z = get_furthest_z()
			var new_z = furthest_z - chunk_length
			
			# 决定下一块要是什类型
			var next_scene_type = decide_next_chunk_type()
			
			# 获取当前这个快要被删掉的块，原本是什么类型
			var current_source = chunk.get_meta("source_scene", null)
			
			# --- 核心优化逻辑 ---
			# 如果“本来就是普通路” 并且 “下一块也是普通路” -> 直接复用！不销毁！
			if current_source == next_scene_type:
				chunk.position.z = new_z # 只做位移，不销毁
				# (如果路块里有吃掉的金币，这里可能需要重置金币，稍后细说)
			
			else:
				# 类型不同（比如要变成断桥了），才忍痛销毁重建
				road_chunks.erase(chunk)
				chunk.queue_free()
				spawn_new_chunk(new_z, next_scene_type)

func get_furthest_z() -> float:
	var min_z = 1000.0
	for chunk in road_chunks:
		if chunk.position.z < min_z:
			min_z = chunk.position.z
	return min_z

func decide_next_chunk_type() -> PackedScene:
	if next_must_be_head:
		next_must_be_head = false
		return road_chunk_gap_head
		
	# 降低一点断桥概率，保证流畅性
	elif randf() < 0.20 and GameManager.current_speed > 12.0:
		next_must_be_head = true 
		return road_chunk_gap
		
	else:
		return road_chunk_scene
