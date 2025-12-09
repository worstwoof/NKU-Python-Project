extends Node3D

# --- 1. 配置参数区 (可以在编辑器里调整) ---
@export_group("核心设置")
@export var road_chunk_scene: PackedScene  # 这里稍后要拖入做好的 RoadChunk.tscn
@export var scroll_speed: float = 20.0     # 路面移动速度 (米/秒)
@export var chunk_count: int = 5           # 场上同时存在的路块数量

# --- 2. 内部变量区 ---
var road_chunks: Array = []   # 用来存放生成的路块引用
var chunk_length: float = 30.0 # 路块的固定长度 (必须和模型一致)

func _ready():
	# 游戏开始时，先铺好第一段路
	spawn_initial_road()

func _process(delta):
	# 每一帧都让路面动起来
	move_road(delta)

# --- 功能函数：初始化生成 ---
func spawn_initial_road():
	# 只有当路块场景被赋值了才运行，防止报错
	if road_chunk_scene == null:
		print("错误：请在检查器中给 Road Chunk Scene 赋值！")
		return

	# 循环生成 N 个路块
	for i in range(chunk_count):
		var new_chunk = road_chunk_scene.instantiate()
		add_child(new_chunk)
		
		# 这里的算法是：第0块在脚下(0)，第1块在前方(-30)，第2块更远(-60)...
		# Godot中，-Z轴是前方
		new_chunk.position.z = 0 - (i * chunk_length)
		
		# 把生成的块加入数组管理
		road_chunks.append(new_chunk)

# --- 功能函数：移动与循环 ---
func move_road(delta):
	for chunk in road_chunks:
		# 1. 移动：让路块沿着 Z 轴正方向（朝向玩家）移动
		chunk.position.z += scroll_speed * delta
		
		# 2. 检查：如果路块跑到了摄像机背后（比如 Z > 30米）
		if chunk.position.z > chunk_length:
			# 把它“瞬移”到队伍的最末尾
			# 新位置 = 当前最远的一个块的位置 - 30米
			recycle_chunk(chunk)

func recycle_chunk(chunk_to_recycle):
	# 找到当前谁在最前面（Z值最小/最负 的那个）
	var furthest_z = chunk_to_recycle.position.z
	for chunk in road_chunks:
		if chunk.position.z < furthest_z:
			furthest_z = chunk.position.z
	
	# 把当前这个跑出界的块，接在最远的那个块后面
	chunk_to_recycle.position.z = furthest_z - chunk_length
