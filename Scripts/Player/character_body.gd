extends CharacterBody3D

# --- 配置参数 ---
const LANE_WIDTH = 4.5  # 跑道宽度：每条道间隔2米（要和生成器保持一致）
@export var LERP_SPEED = 10.0 # 换道的平滑速度（越大越快）

# --- 状态变量 ---
var current_lane: int = 0  # 当前跑道索引：-1(左), 0(中), 1(右)
var target_x: float = 0.0  # 目标X坐标
# 获取护盾节点 (确保你的节点名是对的)
@onready var shield_mesh = $ShieldMesh 

# --- 新增：跳跃参数 ---
@export var JUMP_VELOCITY = 25 # 跳跃力度 (根据手感微调)
# 获取 Godot 全局设置的重力值 (默认是 9.8)
@export var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 10 # 乘2会让下落更快，手感更干脆

# --- UDP 变量 ---
var udp_server := UDPServer.new()
var udp_peer: PacketPeerUDP
const PORT = 4242

# 记录上一帧的跳跃状态，防止连跳
var last_jump_cmd = "NO" 

func _ready():
	update_target_pos()
	# 监听游戏结束，把自己藏起来
	GameManager.connect("game_over", Callable(self, "_on_game_over"))
		# 连接 GameManager 的信号
	GameManager.connect("invincibility_changed", Callable(self, "_on_invincibility_changed"))
	
	# 游戏开始时，默认隐藏护盾
	shield_mesh.visible = false
	
	GameManager.connect("magnet_state_changed", Callable(self, "_on_magnet_changed"))
	
		# 启动 UDP 监听
	var err = udp_server.listen(PORT)
	if err != OK:
		print("UDP 启动失败！端口可能被占用")
	else:
		print("UDP 监听中... 端口: ", PORT)
		
func _process(delta):
	# 每一帧检查有没有收到 Python 的数据
	udp_server.poll()
	if udp_server.is_connection_available():
		udp_peer = udp_server.take_connection()
		
	if udp_peer:
		var packet = udp_peer.get_packet()
		if packet.size() > 0:
			var msg = packet.get_string_from_utf8()
			# msg 格式是 "LEFT,NO" 或 "CENTER,JUMP"
			handle_ai_input(msg)

#   Player.gd
  
func handle_ai_input(msg: String):
	var parts = msg.split(",")
	if parts.size() < 2: return
	
	var move_cmd = parts[0]
	var action_cmd = parts[1]
	
	# --- 移动 ---
	if move_cmd == "LEFT":
		if current_lane != -1: change_lane_to(-1)
	elif move_cmd == "RIGHT":
		if current_lane != 1: change_lane_to(1)
	elif move_cmd == "CENTER":
		if current_lane != 0: change_lane_to(0)
		
	# --- 动作 ---
	if action_cmd == "JUMP":
		# 触发跳跃
		try_jump()
		
	elif action_cmd == "PUNCH":
		# 触发破墙
		# 模拟按下一次空格键
		var ev = InputEventAction.new()
		ev.action = "ui_accept"
		ev.pressed = true
		Input.parse_input_event(ev)
		
		# 关键：为了防止模拟按住不放，我们立刻再模拟一次松开（虽然对于你的破墙逻辑可能不需要，但这样更规范）
		var ev_release = InputEventAction.new()
		ev_release.action = "ui_accept"
		ev_release.pressed = false
		Input.parse_input_event(ev_release)
		
		print("AI: 👊 握拳攻击！")
	

# 把跳跃逻辑封装一下
func try_jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
#func _input(event):
	## 监听按键按下的一瞬间（而不是按住）
	#if event.is_action_pressed("ui_left"):
		#change_lane(-1) # 向左换道
	#elif event.is_action_pressed("ui_right"):
		#change_lane(1)  # 向右换道

# 修改一下你原来的 change_lane，为了支持绝对位置跳转
func change_lane_to(target_lane_index: int):
	current_lane = target_lane_index
	update_target_pos()
#func change_lane(direction: int):
	## 计算新跑道
	#var new_lane = current_lane + direction
	#
	## 限制范围在 -1 到 1 之间 (左、中、右)
	#if new_lane >= -1 and new_lane <= 1:
		#current_lane = new_lane
		#update_target_pos()

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
