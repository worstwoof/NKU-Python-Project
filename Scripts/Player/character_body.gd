extends CharacterBody3D

# --- 配置参数 ---
const LANE_WIDTH = 3.5  # 跑道宽度：每条道间隔2米（要和生成器保持一致）
const LERP_SPEED = 10.0 # 换道的平滑速度（越大越快）

# --- 状态变量 ---
var current_lane: int = 0  # 当前跑道索引：-1(左), 0(中), 1(右)
var target_x: float = 0.0  # 目标X坐标
# 获取护盾节点 (确保你的节点名是对的)
@onready var shield_mesh = $ShieldMesh 

# --- 新增：跳跃参数 ---
const JUMP_VELOCITY = 25 # 跳跃力度 (根据手感微调)
# 获取 Godot 全局设置的重力值 (默认是 9.8)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 10 # 乘2会让下落更快，手感更干脆

func _ready():
	update_target_pos()
	# 监听游戏结束，把自己藏起来
	GameManager.connect("game_over", Callable(self, "_on_game_over"))
		# 连接 GameManager 的信号
	GameManager.connect("invincibility_changed", Callable(self, "_on_invincibility_changed"))
	
	# 游戏开始时，默认隐藏护盾
	shield_mesh.visible = false
	
	GameManager.connect("magnet_state_changed", Callable(self, "_on_magnet_changed"))

func _input(event):
	# 监听按键按下的一瞬间（而不是按住）
	if event.is_action_pressed("ui_left"):
		change_lane(-1) # 向左换道
	elif event.is_action_pressed("ui_right"):
		change_lane(1)  # 向右换道

func change_lane(direction: int):
	# 计算新跑道
	var new_lane = current_lane + direction
	
	# 限制范围在 -1 到 1 之间 (左、中、右)
	if new_lane >= -1 and new_lane <= 1:
		current_lane = new_lane
		update_target_pos()

func update_target_pos():
	# 根据跑道索引计算世界坐标 X
	target_x = current_lane * LANE_WIDTH

func _physics_process(delta):
	# 1. 应用重力 (如果在空中的话)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. 处理跳跃输入 (按下空格/上箭头)
	# ui_accept 默认绑定了 空格 和 Enter
	# ui_up 默认绑定了 上箭头
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		# 这里可以播放一个跳跃音效

	# 3. 处理左右移动 (X轴)
	# 我们只修改 position.x，不修改 velocity.x，因为我们用 lerp 模拟滑步
	position.x = lerp(position.x, target_x, LERP_SPEED * delta)
	
	# 4. 锁定 Z 轴
	position.z = 0 
	
	# 5. 执行物理移动 (这会自动处理 velocity.y 的垂直运动)
	move_and_slide()
	if global_position.y < -10.0:
		print("玩家掉落虚空！")
		# 直接扣除 100 点血量，确保立即死亡
		GameManager.change_hp(-100)
func _on_game_over():
	# 隐藏玩家模型，制造“被摧毁”的假象
	visible = false

# 这是信号的回调函数
func _on_invincibility_changed(is_active: bool):
	#print("玩家收到无敌信号: ", is_active) 
	if is_active:
		shield_mesh.visible = true
	else:
		shield_mesh.visible = false

func _on_magnet_changed(is_active):
	# 开启或关闭引力场的监测
	$MagnetZone.monitoring = is_active
	
	 #可选：加个紫色的粒子特效圈，提示玩家现在有磁铁
	 #$MagnetParticles.emitting = is_active
