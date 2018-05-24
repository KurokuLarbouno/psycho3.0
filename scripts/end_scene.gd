extends Node2D

var p1_kills = 0
var p1_k_flag = false
var p1_deaths = 0
var p1_d_flag = false
var p1_total = 0
var p1_total_flag = false

var p2_kills = 0
var p2_k_flag = false
var p2_deaths = 0
var p2_d_flag = false
var p2_total = 0
var p2_total_flag = false

var p3_kills = 0
var p3_k_flag = false
var p3_deaths = 0
var p3_d_flag = false
var p3_total = 0
var p3_total_flag = false

var p4_kills = 0
var p4_k_flag = false
var p4_deaths = 0
var p4_d_flag = false
var p4_total = 0
var p4_total_flag = false

var no_kills = 0
var no_deaths = 0

var player_data = []
var final_score = []
var t = 0
var backt = 0
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
	back_to_main(delta)
	pass

func update_score(delta):
	
	t += delta
	if(t > 0.3):
		#player 1
		if(p1_kills < final_score[0][0]):
			p1_kills += 1
			get_node("1/kills").scale = Vector2(2,2)
		else: p1_k_flag = true
		if(p1_deaths < final_score[0][1]):
			p1_deaths += 1
			get_node("1/deaths").scale = Vector2(2,2)
		else: p1_d_flag = true
		if(p1_k_flag and p1_d_flag and !p1_total_flag):
			p1_total = final_score[0][0] - final_score[0][1]
			get_node("1/final").scale = Vector2(5,5)
			get_node("1/final").show()
			p1_total_flag = true
		get_node("1/kills/total kills").text = str(p1_kills)
		get_node("1/deaths/total deaths").text = str(p1_deaths)
		get_node("1/final/score").text = str(p1_total)
		#player 2
		if(p2_kills < final_score[1][0]):
			p2_kills += 1
			get_node("2/kills").scale = Vector2(2,2)
		else: p2_k_flag = true
		if(p2_deaths < final_score[1][1]):
			p2_deaths += 1
			get_node("2/deaths").scale = Vector2(2,2)
		else: p2_d_flag = true
		if(p2_k_flag and p2_d_flag and !p2_total_flag):
			p2_total = final_score[1][0] - final_score[1][1]
			get_node("2/final").scale = Vector2(5,5)
			get_node("2/final").show()
			p2_total_flag = true
		get_node("2/kills/total kills").text = str(p2_kills)
		get_node("2/deaths/total deaths").text = str(p2_deaths)
		get_node("2/final/score").text = str(p2_total)
		#player 3
		if(p3_kills < final_score[2][0]):
			p3_kills += 1
			get_node("1/kills").scale = Vector2(2,2)
		else: p3_k_flag = true
		if(p3_deaths < final_score[2][1]):
			p3_deaths += 1
			get_node("3/deaths").scale = Vector2(2,2)
		else: p3_d_flag = true
		if(p3_k_flag and p3_d_flag and !p3_total_flag):
			p3_total = final_score[2][0] - final_score[2][1]
			get_node("3/final").scale = Vector2(5,5)
			get_node("3/final").show()
			p3_total_flag = true
		get_node("3/kills/total kills").text = str(p3_kills)
		get_node("3/deaths/total deaths").text = str(p3_deaths)
		get_node("3/final/score").text = str(p3_total)
		#player 4
		if(p4_kills < final_score[3][0]):
			p4_kills += 1
			get_node("4/kills").scale = Vector2(2,2)
		else: p4_k_flag = true
		if(p4_deaths < final_score[3][1]):
			p4_deaths += 1
			get_node("4/deaths").scale = Vector2(2,2)
		else: p4_d_flag = true
		if(p4_k_flag and p4_d_flag and !p4_total_flag):
			p4_total = final_score[3][0] - final_score[3][1]
			get_node("4/final").scale = Vector2(5,5)
			get_node("4/final").show()
			p4_total_flag = true
		get_node("4/kills/total kills").text = str(p4_kills)
		get_node("4/deaths/total deaths").text = str(p4_deaths)
		get_node("4/final/score").text = str(p4_total)
		t = 0
	for i in range(4):
		if(get_node(str(i+1) + "/kills").scale.x > 1):
			get_node(str(i+1) + "/kills").scale -= Vector2(0.1, 0.1)
		if(get_node(str(i+1) + "/deaths").scale.x > 1):
			get_node(str(i+1) + "/deaths").scale -= Vector2(0.1, 0.1)
		if(get_node(str(i+1) + "/final").scale.x > 1):
			get_node(str(i+1) + "/final").scale -= Vector2(0.1, 0.1)
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
func back_to_main(delta):
	backt += delta
	if(backt > 10):
		if(Input.is_joy_button_pressed(0, 0)):
			get_node("../../../..")._load_scene("res://scene/lobby.tscn")
	pass