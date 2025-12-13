extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	# 同样使用全局速度
	global_translate(Vector3(0, 0, GameManager.current_speed * delta))
	rotate_y(3.0 * delta) # 自转
	
	if global_position.z > 10:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.change_hp(1) # 加血
		# 播放一个治愈的音效
		queue_free()
