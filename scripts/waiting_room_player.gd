extends Node2D
var device_num
var character_name = {1 : "Slice", 2 : "Acid", 3 : "Beast", 4 : "Phase"}
var Slice = load("res://image/StartEnd/c1.png")
var Acid = load("res://image/StartEnd/c2.png")
var Beast = load("res://image/StartEnd/c3.png")
var Phase = load("res://image/StartEnd/c4.png")
var character_order = 0 # 0 = Slice; 1 = Acid; 2 = Beast; 4 = Phase

var pname 
var button = 0
var button_max = 2
var player_state = 0
var t = 0
func _ready():
	$player.text = pname
	pass

func _process(delta):
	print(player_state)
	if(player_state == 0):
		t = 0
		button_selet()
		_button_pressed()
	elif(player_state == 1):#ready
		_button_cancel()
	elif(player_state == 2):
		t += 1
		if(t > 100):
			player_state = 0;
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
	var buttons = $buttons.get_children()
	for i in range($buttons.get_children().size()):
		buttons[i].deselect_button()
	if(button == 0):
		$buttons/left.select_button()
	elif(button == 1):
		$buttons/right.select_button()
	elif(button == 2):
		$buttons/ready.select_button()
	pass
#按下按鈕
func _button_pressed():
	if(Input.is_joy_button_pressed(device_num, 0)):
		var buttons = $buttons.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 1):
				buttons[i].button_pressed()
				if(buttons[i] == $buttons/ready):
					player_state = 1
				elif(buttons[i] == $buttons/right):
					if(character_order < 3):
						character_order += 1
					else:
						character_order = 0
					change_character()
				elif(buttons[i] == $buttons/left):
					if(character_order > 0):
						character_order -= 1
					else:
						character_order = 3
					change_character()
	pass
#取消選取
func _button_cancel():
	if(Input.is_joy_button_pressed(device_num, 1)):
		var buttons = $buttons.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 2):
				buttons[i].deselect_button()
				buttons[i].select_button()
				player_state = 2
func change_character():
	if(character_order == 0):
		$cName.text = character_name[1]
		$player_icon.texture = Slice
	elif(character_order == 1):
		$cName.text = character_name[2]
		$player_icon.texture = Acid
	elif(character_order == 2):
		$cName.text = character_name[3]
		$player_icon.texture = Beast
	elif(character_order == 3):
		$cName.text = character_name[4]
		$player_icon.texture = Phase
	pass
