extends Node2D

var p1_kills = 0
var p1_deaths = 0
var p2_kills = 0
var p2_deaths = 0
var p3_kills = 0
var p3_deaths = 0
var p4_kills = 0
var p4_deaths = 0

var player_data = []
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
	show_player()
	update_score(delta)
	pass

func update_score(delta):
	t += delta
	if(t > 1):
		#player 1
		if(p1_kills < final_score[0][0]):
			p1_kills += 1
		if(p1_deaths < final_score[0][1]):
			p1_deaths += 1
		$"1/total kills".text = str(p1_kills)
		$"1/total deaths".text = str(p1_deaths)
		#player 2
		if(p2_kills < final_score[1][0]):
			p2_kills += 1
		if(p2_deaths < final_score[1][1]):
			p2_deaths += 1
		$"2/total kills".text = str(p2_kills)
		$"2/total deaths".text = str(p2_deaths)
		#player 3
		if(p3_kills < final_score[2][0]):
			p3_kills += 1
		if(p3_deaths < final_score[2][1]):
			p3_deaths += 1
		$"3/total kills".text = str(p3_kills)
		$"3/total deaths".text = str(p3_deaths)
		#player 4
		if(p4_kills < final_score[3][0]):
			p4_kills += 1
		if(p4_deaths < final_score[3][1]):
			p4_deaths += 1
		$"4/total kills".text = str(p4_kills)
		$"4/total deaths".text = str(p4_deaths)
		t = 0
	pass
var show = false
func show_player():
	if(!show):
		if(player_data[0][0] == 1):
			$"1".show()
		if(player_data[1][0] == 1):
			$"2".show()
		if(player_data[2][0] == 1):
			$"3".show()
		if(player_data[3][0] == 1):
			$"4".show()
		show = true
	pass
func back_to_main():
	pass