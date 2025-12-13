extends Area3D

@export var score_amount: int = 10         # 吃到加多少分
@export var extra_speed: float = 0.0       # 额外速度 (在全局速度基础上加多少)
@export var rotate_speed: float = 2.0      # 自转速度
var target_player: Node3D = null # 记录要飞向谁

# 被引力场调用的函数
func start_magnet(player_node):
	target_player = player_node

func _physics_process(delta):
	var final_speed = GameManager.current_speed + extra_speed
	if target_player:
		# --- 磁铁模式：飞向玩家 ---
		var direction = (target_player.global_position - global_position).normalized()
		# 加上一点 y 轴偏移，让它飞向玩家胸口而不是脚底
		direction.y += 0.2 
		global_translate(direction * final_speed * delta)
	else:
		# --- 正常模式：向后移动 ---
		global_translate(Vector3(0, 0, final_speed * delta))
		
	rotate_y(5.0 * delta) # 转快点
	
	if global_position.z > 10:
		queue_free()

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":

		GameManager.add_score(score_amount)
		queue_free()
