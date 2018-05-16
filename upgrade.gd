extends Node2D

var state = 0
var player_stats
var player_score

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if(state == 0):
		spawn_players()
		state = 1
	pass

func spawn_players():
	for i in range(4):
		var player_data = get_node("../..").player_data[i][0]
		if(player_data == 1):
			var player = load("res://scene/upgrade_player.tscn").instance()
			player_stats[i] = player.stats
			player_score[i] = player.score
			get_node("player/player" + str(i+1)).add_child(player)
			
	pass