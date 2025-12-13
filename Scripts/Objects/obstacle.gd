extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# 【关键修改】使用 GameManager 的全局速度！
	# 这样吃到加速金币后，所有障碍物都会变快
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	
	if global_position.z > 10:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		# 【修改】检查是否无敌
		if GameManager.is_invincible:
			print("玩家粉碎了障碍物！")
			# 可以在这里加 10 分
			# 播放破碎特效 (Particles)
			queue_free() # 障碍物自己销毁，不扣血
		else:
			# 原来的逻辑：扣血
			GameManager.change_hp(-1)
			queue_free()
