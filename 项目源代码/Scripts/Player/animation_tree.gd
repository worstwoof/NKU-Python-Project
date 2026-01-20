extends AnimationTree
var game_manager_node:Node
var moving_speed
var is_on_floor_state
var player_node:Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.active = true
	game_manager_node=get_node("/root/GameManager")
	player_node=get_node("/root/Main/Player")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	moving_speed=game_manager_node.current_speed
	is_on_floor_state=player_node.is_on_floor()
	
