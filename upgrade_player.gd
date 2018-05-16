extends Node2D

var main_button # 0 = body; 1 = gun; 2 = ready
var state = 0
var device_num

func _ready():
	$AnimationPlayer.play("hologram")
	pass

func _process(delta):
	if(state == 0):
		main_button_select()
		main_button_pressed()
	elif(state == 1):
		body_button_select()
	elif(state == 2):
		gun_button_select()
	pass
func main_button_select():
	#up
	if(Input.get_joy_axis(device_num,1) < -0.3):
		if(button == 1):
			button = 0
			main_button_focus()
		elif(button == 2):
			button = 1
			main_button_focus()
	#down
	elif(Input.get_joy_axis(device_num,1) > 0.3):
		if(button == 0):
			button = 1
			main_button_focus()
		elif(button == 1):
			button = 2
			main_button_focus()
	pass
func main_button_focus():
	var buttons = $menu/main.get_children()
	for i in range(buttons.size()):
		buttons[i].deselect_button()
	if(button == 0):
		$menu/main/bodyUpgrade.select_button()
	elif(button == 1):
		$menu/main/gunUpgrade.select_button()
	elif(button == 2):
		$menu/main/ready.select_button()
	pass
func main_button_pressed():
	if(Input.is_joy_button_pressed(device_num, 0)):
		var buttons = $menu/main.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 1):
				buttons[i].button_pressed()
				if(buttons[i] == $menu/main/bodyUpgrade):
					$menu/main.hide()
					$menu/body.show()
					state = 1
				elif(button[i] == $menu/main/gunUpgrade):
					$menu/main.hide()
					$menu/guns.show()
					state = 2
				elif(button[i] == $menu/main/ready):
					$menu/main.hide()
					$menu/ready.show()
	pass
