extends CSGCylinder3D # 如果你用的是MeshInstance3D，请把这里改成 MeshInstance3D

# 出现概率：0.0 = 从不出现，1.0 = 100%出现，0.7 = 70%概率出现
@export_range(0.0, 1.0) var spawn_chance: float = 0.7



func _ready():
	# 1. 掷骰子决定生死
	# randf() 会返回 0.0 到 1.0 之间的随机数
	if randf() > spawn_chance:
		queue_free() # 运气不好，自我销毁
		return # 既然销毁了，后面就不用执行了
