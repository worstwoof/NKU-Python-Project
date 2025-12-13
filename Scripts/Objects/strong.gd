extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# 移动和自转逻辑 (和金币一样)
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	rotate_y(2.0 * delta)
	rotate_x(2.0 * delta)
	# 甚至可以加个 rotate_x 让它斜着转，更有科技感
	
	if global_position.z > 10:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		# 激活 5 秒无敌
		GameManager.activate_invincibility(5.0)
		queue_free()
