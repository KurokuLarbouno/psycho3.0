extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var upgrade_state = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if(upgrade_state == 0):
		spawn_players()
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass
func spawn_players():
	for i in range(4):
		if(get_node("../../game_controller").)
pass
