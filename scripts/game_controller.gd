extends Node2D

signal int_game
signal game_over

var game1 = "res://scene/Game2.tscn"
var game2 = "res://scene/Game.tscn"

var gameState = 0

func _ready():
	# Called every time the node i added to the scene.
	
	emit_signal("int_game")
	pass

func _process(delta):
	if(gameState == 0):
		emit_signal("int_game")
		_load_game(game1)
	pass
var cur_game = ""

func _load_game(scn):
	cur_game = scn
	var children = $game_scene.get_children()
	if(children.size() > 0):
		children[0].queue_free()
		print("free game_scene")
	var act = load(cur_game).instance()
	$game_scene.add_child(act)
	pass
func is_level():
	pass