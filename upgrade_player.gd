extends Node2D

var main_button = 0# 0 = body; 1 = gun; 2 = ready
var body_button = 0
var state = 0
var device_num
var t = 0
var button_delay = 0.2

func _ready():
	$AnimationPlayer.play("hologram")
	main_button_focus()
	pass

func _process(delta):
	if(state == 0): #main menu
		main_button_select(delta)
		main_button_pressed()
	elif(state == 1): #body menu
		body_button_select(delta)
		body_button_pressed()
		body_exit()
	elif(state == 2): #gun menu
		gun_button_select()
	pass
	
	#main button
func main_button_select(delta):
	t += delta
	if(t > button_delay):
	#up
		if(Input.get_joy_axis(device_num,1) < -0.3):
			if(main_button == 1):
				main_button = 0
			elif(main_button == 2):
				main_button = 1
			main_button_focus()
		#down
		elif(Input.get_joy_axis(device_num,1) > 0.3):
			if(main_button == 0):
				main_button = 1
			elif(main_button == 1):
				main_button = 2
			main_button_focus()
		t = 0
	pass
func main_button_focus():
	var buttons = $menu/main.get_children()
	for i in range(buttons.size()):
		buttons[i].deselect_button()
	if(main_button == 0):
		$menu/main/bodyUpgrade.select_button()
	elif(main_button == 1):
		$menu/main/gunUpgrade.select_button()
	elif(main_button == 2):
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
				elif(buttons[i] == $menu/main/gunUpgrade):
					$menu/main.hide()
					$menu/guns.show()
					state = 2
				elif(buttons[i] == $menu/main/ready):
					$menu/main.hide()
					$menu/ready.show()
	pass
	#body button
func body_button_select(delta):
	t +=1
	if(t > button_delay): 
		#up
		if(Input.get_joy_axis(device_num,1) < -0.3):
			if(body_button == 1):
				body_button = 0
			body_button_focus()
		#down
		elif(Input.get_joy_axis(device_num,1) > 0.3):
			if(body_button == 0):
				body_button = 1
			body_button_focus()
		t = 0
	pass
func body_button_focus():
	var buttons = $menu/body.get_children()
	for i in range(buttons.size()):
		buttons[i].deselect_button()
	if(body_button == 0):
		$menu/body/health.select_button()
	elif(body_button == 1):
		$menu/body/speed.select_button()
	pass
func body_button_pressed():
	
	pass
func body_exit():
	if(Input.is_joy_button_pressed(device_num, 1)):
		$menu/body.hide()
		$menu/main.show()
		state = 0
func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "hologram"):
		$menu.show()
	pass # replace with function body
