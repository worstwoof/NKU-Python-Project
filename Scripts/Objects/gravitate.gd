extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	rotate_y(2.0 * delta)
	rotate_z(1.0 * delta) # 让它转得更魔幻一点
	
	if global_position.z > 10:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		# 激活 10 秒磁铁
		GameManager.activate_magnet(10.0)
		
		# 播放音效 (可选)
		# AudioManager.play("magnet_powerup")
		
		queue_free()
