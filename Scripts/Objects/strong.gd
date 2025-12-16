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
var is_collected: bool = false
func _on_body_entered(body):
	if body.name == "Player":
		# 激活 5 秒无敌
		GameManager.activate_invincibility(5.0)
		if is_collected or body.name != "Player":
			return
	
		# 3. 立即上锁
		is_collected = true
		$AudioStreamPlayer.play()
		
		$CSGCombiner3D.visible = false
		$CollisionShape3D.set_deferred("disabled", true)

		#await get_tree().create_timer(1.0).timeout
		await $AudioStreamPlayer.finished
		queue_free()
