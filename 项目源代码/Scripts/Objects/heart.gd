extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# 同样使用全局速度
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	rotate_y(3.0 * delta) # 自转
	
	if global_position.z > 10:
		queue_free()
var is_collected: bool = false
func _on_body_entered(body):
	if body.name == "Player":
		if is_collected:
			return
		is_collected = true
		
		GameManager.change_hp(1) # 加血
		# 播放一个治愈的音效
		$AudioStreamPlayer.play()
		
		$Heart.visible = false
		$CollisionShape3D.set_deferred("disabled", true)

		#await get_tree().create_timer(1.0).timeout
		await $AudioStreamPlayer.finished
		queue_free()
