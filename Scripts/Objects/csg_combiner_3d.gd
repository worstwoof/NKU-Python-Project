extends CSGCombiner3D

@export var damage: int = 5
@export var move_speed: float = 4.0

func _ready():
	# 当玩家撞到障碍物时触发
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# 障碍物向玩家方向移动（假设玩家在 z = 0 位置）
	global_translate(Vector3(0, 0, move_speed * delta))

	# 移出视野就删除
	if global_transform.origin.z > 10:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		print("玩家撞到障碍物！伤害：", damage)
