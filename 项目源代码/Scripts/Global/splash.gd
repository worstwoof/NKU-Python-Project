extends Control

# --- 配置区域 ---
# 在这里填入你第一关场景的路径
# 你也可以在编辑器右侧属性面板里直接拖拽场景文件进来
@export_file("*.tscn") var game_scene_path: String = "res://Scenes/Prefabs/main.tscn" 

func _ready():
	# (可选) 游戏一开始把焦点给“开始游戏”按钮，方便键盘操作
	# 如果你的按钮名字不一样，记得改下面这一行
	if has_node("MenuButtons/HostGameBtn"):
		$MenuButtons/HostGameBtn.grab_focus()

# --- 信号连接函数 ---

# 连接给 "PLAY GAME" 按钮
func _on_play_pressed():
	print("🔴 按钮被点击了！")
	if game_scene_path == "":
		print("❌ 错误：你还没设置游戏场景的路径！")
		return
	
	# 切换场景
	get_tree().change_scene_to_file(game_scene_path)

# 连接给 "QUIT" 按钮
func _on_quit_pressed():
	print("👋 正在退出游戏...")
	get_tree().quit()


func _on_host_game_btn_pressed() -> void:
	pass # Replace with function body.


func _on_host_game_btn_2_pressed() -> void:
	pass # Replace with function body.
