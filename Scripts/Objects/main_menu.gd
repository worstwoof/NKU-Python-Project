extends Control

func _ready():
	# 连接按钮信号
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	# 加载主游戏场景 (确保路径正确)
	get_tree().change_scene_to_file("res://Scenes/Prefabs/main.tscn")

func _on_quit_pressed():
	get_tree().quit()
