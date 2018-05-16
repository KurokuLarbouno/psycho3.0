extends Node2D

var state = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$Camera2D.make_current() 
	pass

func _process(delta):
	if(state == 0):
		spawn_players()
		state = 1
	pass

func spawn_players():
	for i in range(4):
		var player_data = get_node("../..").player_data
		if(player_data[i][0] == 1):
			var player = load("res://scene/upgrade_player.tscn").instance()
			player.device_num = player_data[i][1]
			get_node("player/player" + str(i+1)).add_child(player)
	pass