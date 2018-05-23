extends Node2D

var p1_kills = 0
var p1_deaths = 0
var p2_kills = 0
var p2_deaths = 0
var final_score = []
var t = 0
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$Camera2D.make_current()
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	update_score(delta)
	pass

func update_score(delta):
	t += delta
	if(t > 1):
		if(p1_kills < final_score[0][0]):
			p1_kills += 1
		if(p1_deaths < final_score[0][1]):
			p1_deaths += 1
		$"1/total kills".text = str(p1_kills)
		$"1/total deaths".text = str(p1_deaths)
		
		if(p2_kills < final_score[1][0]):
			p2_kills += 1
		if(p2_deaths < final_score[1][1]):
			p2_deaths += 1

		$"2/total kills".text = str(p2_kills)
		$"2/total deaths".text = str(p2_deaths)
		t = 0
	pass