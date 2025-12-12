extends MeshInstance3D

var speed = -5 # 背景移动慢一点，营造视差感

func _process(delta):
	# 获取材质 (确保材质设为 Local to Scene 或者只有一个实例)
	var mat = get_active_material(0)
	# 移动 UV 的 Y 轴 (在 UV 空间里 Y 通常对应 3D 的 Z)
	mat.uv1_offset.y += speed * delta
