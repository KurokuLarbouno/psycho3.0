extends Node2D

signal next_round

var state = 0
var player_stats = []
var player_score = []
var player_count = 0
var ready_player = 0

func _ready():
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
			player.player_num = i
			player.device_num = get_node("../..").player_data[i][1] 
			player.stats = player_stats
			player.score = player_score 
			player.connect("upgrade_ready", self, "_upgrade_ready")
			get_node("player/player" + str(i+1)).add_child(player)
			player_count += 1
	pass
func _upgrade_ready():
	ready_player += 1
	if(ready_player == player_count):
		emit_signal("next_round")
	pass