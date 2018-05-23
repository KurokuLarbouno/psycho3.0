extends Node2D

var final_score = []
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$Camera2D.make_current()
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	update_score()
	pass

func update_score():
	$"1/total kills".text = str(final_score[0][0])
	$"1/total deaths".text = str(final_score[0][1])
	
	pass