extends Area3D

func _ready():
	# 连接“有东西进入引力场”的信号
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area):
	# 如果进入圈内的是金币，就叫它飞过来
	# 我们需要在金币脚本里写一个 "attract" 函数
	if area.has_method("start_magnet"):
		area.start_magnet(get_parent()) # 把玩家节点传给金币
