extends Node2D

signal player_ready
signal player_delete

var device_num
var character_name = {1 : "Slice", 2 : "Acid", 3 : "Beast", 4 : "Phase"}
var Slice = load("res://image/StartEnd/c1.png")
var Acid = load("res://image/StartEnd/c2.png")
var Beast = load("res://image/StartEnd/c3.png")
var Phase = load("res://image/StartEnd/c4.png")
var character_order = 0 # 0 = Slice; 1 = Acid; 2 = Beast; 4 = Phase
var player_num = 0

var pname 
var button = 0
var button_max = 2
var player_state = 0 # 0 = normal; 1 = ready; 2 = loading ; 3 = exit
var t = 0
func _ready():
	button_connect()
	$items/player.text = pname
	open()
	pass

func _process(delta):
	#print(player_state)
	if(player_state == 0):
		t = 0
		button_selet()
		_button_pressed()
	elif(player_state == 1):#ready
		_button_cancel()
	elif(player_state == 2):
		t += 1
		if(t > 20):
			player_state = 0
	pass
#搖桿蘑菇頭選擇
func button_selet():
	#left
	if(Input.get_joy_axis(device_num,0) < -0.3): 
		if(button == 1):
			button -= 1
			button_focus()
	#right
	elif(Input.get_joy_axis(device_num,0) > 0.3):
		if(button == 0):
			button += 1
			button_focus()
	#up
	elif(Input.get_joy_axis(device_num,1) < -0.3):
		if(button == 2):
			button = 1
			button_focus()
	#down
	elif(Input.get_joy_axis(device_num,1) > 0.3):
		if(button < 2):
			button = 2
			button_focus()
	pass
#按鈕選取
func button_focus():
	var buttons = $items/buttons.get_children()
	for i in range($items/buttons.get_children().size()):
		buttons[i].deselect_button()
	if(button == 0):
		$items/buttons/left.select_button()
	elif(button == 1):
		$items/buttons/right.select_button()
	elif(button == 2):
		$items/buttons/ready.select_button()
	pass
#按下按鈕
func _button_pressed():
	if(Input.is_joy_button_pressed(device_num, 0)):
		var buttons = $items/buttons.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 1):
				buttons[i].button_pressed()
				if(buttons[i] == $items/buttons/ready):
					player_state = 1
					emit_signal("player_ready", 1, player_num, character_order)
				elif(buttons[i] == $items/buttons/right):
					if(character_order < 3):
						character_order += 1
					else:
						character_order = 0
					change_character()
				elif(buttons[i] == $items/buttons/left):
					if(character_order > 0):
						character_order -= 1
					else:
						character_order = 3
					change_character()
	pass
#取消選取
func _button_cancel():
	if(Input.is_joy_button_pressed(device_num, 1)):
		var buttons = $items/buttons.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 2):
				buttons[i].deselect_button()
				buttons[i].select_button()
				player_state = 2
				emit_signal("player_ready", -1, -1, -1)
func change_character():
	if(character_order == 0):
		$items/cName.text = character_name[1]
		$items/player_icon.texture = Slice
	elif(character_order == 1):
		$items/cName.text = character_name[2]
		$items/player_icon.texture = Acid
	elif(character_order == 2):
		$items/cName.text = character_name[3]
		$items/player_icon.texture = Beast
	elif(character_order == 3):
		$items/cName.text = character_name[4]
		$items/player_icon.texture = Phase
	pass
func _lmouse_click():
	if(character_order > 0):
		character_order -= 1
	else:
		character_order = 3
	change_character()
	pass
func _rmouse_click():
	if(character_order < 3):
		character_order += 1
	else:
		character_order = 0
	change_character()
	pass

func _rdmouse_click():
	player_state = 1
	pass
func character_repeat():
	
	pass
func button_connect():
	$items/buttons/left.connect("lmouse_click", self, "_lmouse_click")
	$items/buttons/right.connect("rmouse_click", self, "_rmouse_click")
	$items/buttons/ready.connect("rdmouse_click", self, "_rdmouse_click")
	pass
func open():
	$AnimationPlayer.play("hologram")
	pass
func exit():
	$items.hide()
	if(player_state != 3):
		$AnimationPlayer.play("exit")
	player_state = 3
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "hologram"):
		$items.show()
	elif(anim_name == "exit"):
		emit_signal("player_delete", self)
	pass # replace with function body
