extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# 【关键修改】使用 GameManager 的全局速度！
	# 这样吃到加速金币后，所有障碍物都会变快
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	
	if global_position.z > 10:
		queue_free()
var is_collected: bool = false
func _on_body_entered(body):
	if body.name == "Player":
		# 【修改】检查是否无敌
		if is_collected:
			return
			
		is_collected = true

		if GameManager.is_invincible:
			print("玩家粉碎了障碍物！")
		else:
			# 原来的逻辑：扣血
			GameManager.change_hp(-1)
		$AudioStreamPlayer.play()
		$CSGCombiner3D.visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		#await get_tree().create_timer(1.0).timeout
		await $AudioStreamPlayer.finished
		queue_free()
