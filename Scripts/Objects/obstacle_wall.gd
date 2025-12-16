extends Area3D

# --- 配置参数 ---
@export var hits_required: int = 3
@export var key_name: String = "ui_accept"
# 【新增】时间限制（秒）
@export var time_limit: float = 3.0 

var current_hits: int = 0
var is_engaged: bool = false
# 【新增】当前剩余时间
var time_left: float = 0.0

@onready var label = $Label3D
@onready var timer_bar = $TimerBarMesh # 刚才做的那个红色长条

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	label.text = "BREAK: %d" % hits_required
	# 初始化时间
	time_left = time_limit

@onready var engage = $engage
func _physics_process(delta):
	# 移动逻辑
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	
	if global_position.z > 10:
		queue_free()

	# ==========================================
	# 👇【核心新增】倒计时逻辑
	# ==========================================
	if is_engaged:
		# 1. 扣除时间
		time_left -= delta
		
		# 2. 更新进度条视觉 (通过缩放 X 轴)
		# 比例 = 剩余时间 / 总时间
		var ratio = time_left / time_limit
		timer_bar.scale.x = ratio
		
		# 变色预警：最后 1 秒变白闪烁 (可选细节)
		#if time_left < 1.0:
			#timer_bar.material_override.albedo_color = Color.WHITE if Engine.get_frames_drawn() % 10 < 5 else Color.RED
		
		# 3. 检查是否超时
		if time_left <= 0:
			trigger_failure() # 触发失败逻辑

func _input(event):
	# 如果已经失败了，就锁死输入，不准再按了
	if time_left <= 0: return

	if is_engaged and event.is_action_pressed(key_name):
		take_hit()

func _on_body_entered(body):
	if body.name == "Player" and not is_engaged:
		is_engaged = true
		GameManager.start_wall_struggle()
		engage.play()

func take_hit():
	current_hits += 1
	var remaining = hits_required - current_hits
	label.text = "BREAK: %d" % remaining
	
	# 简单的受击动画
	var tween = create_tween()
	tween.tween_property($CSGCombiner3D, "scale", Vector3(1.1, 1.1, 1.1), 0.05)
	tween.tween_property($CSGCombiner3D, "scale", Vector3(1.0, 1.0, 1.0), 0.05)
	
	if current_hits >= hits_required:
		break_wall_success() # 改名了，区分成功和失败

# --- ✅ 成功击破 ---
@onready var wall_break = $wall_break
func break_wall_success():
	GameManager.end_wall_struggle()
	#GameManager.add_score(30) # 只有成功才加分
	engage.stop()
	wall_break.play()
	# 粒子特效 & 销毁 (复用之前的逻辑)
	spawn_particles_and_die()

# --- ❌ 超时失败 ---
func trigger_failure():
	print("破解失败！防火墙反噬！")
	
	# 1. 扣血！
	GameManager.change_hp(-1)
	
	# 2. 依然要恢复速度 (不然游戏就卡死在这里了)
	GameManager.end_wall_struggle()
	
	# 3. 播放失败特效 (比如墙变黑消失，而不是炸开)
	# 这里简单处理：直接销毁，或者播一个红色的粒子
	spawn_particles_and_die()

# 公共的销毁逻辑
func spawn_particles_and_die():
	$CSGCombiner3D.visible = false
	label.visible = false
	timer_bar.visible = false
	$CollisionShape3D.disabled = true
	
	# 假设你有粒子节点
	if has_node("GPUParticles3D"):
		$GPUParticles3D.emitting = true
		await get_tree().create_timer(1.0).timeout
	
	queue_free()
