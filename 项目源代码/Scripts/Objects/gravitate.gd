extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	rotate_y(2.0 * delta)
	rotate_z(1.0 * delta) # 让它转得更魔幻一点
	
	if global_position.z > 10:
		queue_free()
var is_collected: bool = false

func _on_body_entered(body):
	if body.name == "Player":
		if is_collected or body.name != "Player":
			return
	
		# 3. 立即上锁
		is_collected = true
		# 激活 10 秒磁铁
		GameManager.activate_magnet(10.0)
		
		$AudioStreamPlayer.play()
		
		$CSGCombiner3D.visible = false
		$CollisionShape3D.set_deferred("disabled", true)
		#await get_tree().create_timer(1.0).timeout
		await $AudioStreamPlayer.finished
		
		queue_free()
