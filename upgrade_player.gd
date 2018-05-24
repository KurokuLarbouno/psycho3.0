extends Node2D

signal upgrade_ready

var main_button = 0 # 0 = body; 1 = gun; 2 = ready
var body_button = 0 # 0 = health; 1 = speed
var gun_button = 0 # 0 = reload speed; 1 =  fire speed; 2 = bullet speed
var state = 0
var device_num
var t = 0
var button_delay = 0.2
var stats = [] #0 = health; 1 = speed
var score = [] #killpoints; deadpoints
var upgrade_total = [0,0,0,0,0]
var player_num
var pressdelay

var upgrade_stats = [0,0,0,0,0]
#升級數值
var health_upgrade = 1
var speed_upgrade = 300
var reload_upgrade = -0.05
var fire_upgrade = -0.01
var bullet_upgrade = 10
func _ready():
	button_connect()
	$menu/player.text = "player" + str(player_num + 1)
	$AnimationPlayer.play("hologram")
	main_button_focus()
	body_button_focus()
	body_stats_update()
	gun_button_focus()
	gun_stats_update()
	pass

func _process(delta):
	upgrade_points_update()
	if(state == 0): #main menu
		main_button_select(delta)
		main_button_pressed()
		main_ui_update()
		pressdelay = 0
	elif(state == 1): #body menu
		pressdelay += 1
		body_button_select(delta)
		if(pressdelay > 20):
			body_button_pressed()
		body_exit()
	elif(state == 2): #gun menu
		pressdelay += 1
		gun_button_select(delta)
		if(pressdelay > 20):
			gun_button_pressed()
		gun_exit()
	elif(state == 3):#ready
		menu_exit()
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
					$menu/UI.hide()
					$menu/body.show()
					$menu/bodyUI.show()
					state = 1
				elif(buttons[i] == $menu/main/gunUpgrade):
					$menu/main.hide()
					$menu/UI.hide()
					$menu/guns.show()
					$menu/gunUI.show()
					state = 2
				elif(buttons[i] == $menu/main/ready):
					$menu/main.hide()
					$menu/UI.hide()
					$menu/ready.show()
					player_ready()
					state = 3
	pass
	#body button
func body_button_select(delta):
	t += delta
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
	if(Input.is_joy_button_pressed(device_num, 0) and (score[player_num][0] > 0)):
		var buttons = $menu/body.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 1):
				buttons[i].button_pressed()
				if((buttons[i] == $menu/body/health) and (upgrade_stats[0] < 5)):
					score[player_num][0] -= 1
					stats[player_num][0] += health_upgrade
					upgrade_total[0] += 1
					upgrade_stats[0] += 1
					body_stats_update()
				elif((buttons[i] == $menu/body/speed) and (upgrade_stats[1] < 5)):
					score[player_num][0] -= 1
					stats[player_num][1] += speed_upgrade
					upgrade_total[1] += 1
					upgrade_stats[1] += 1
					body_stats_update()
	pass
func body_stats_update():
	$menu/body/health/Label.text = str(stats[player_num][0])
	$menu/body/speed/Label.text = str(stats[player_num][1])
	upgrade_points_update()
	pass
func body_exit():
	if(Input.is_joy_button_pressed(device_num, 1)):
		$menu/body.hide()
		$menu/bodyUI.hide()
		$menu/main.show()
		$menu/UI.show()
		state = 0
	elif(device_num == 4): #鍵盤
		if (Input.is_action_pressed("ui_accept")):
			$menu/body.hide()
			$menu/bodyUI.hide()
			$menu/main.show()
			$menu/UI.show()
			state = 0
	#gun button
func gun_button_select(delta):
	t += delta
	if(t > button_delay): 
		#up
		if(Input.get_joy_axis(device_num,1) < -0.3):
			if(gun_button == 1):
				gun_button -= 1
			elif(gun_button == 2):
				gun_button -= 1
			gun_button_focus()
		#down
		elif(Input.get_joy_axis(device_num,1) > 0.3):
			if(gun_button == 0):
				gun_button += 1
			elif(gun_button == 1):
				gun_button += 1
			gun_button_focus()
		t = 0
	pass
func gun_button_focus():
	var buttons = $menu/guns.get_children()
	for i in range(buttons.size()):
		buttons[i].deselect_button()
	if(gun_button == 1):
		$menu/guns/reloadSpeed.select_button()
	elif(gun_button == 0):
		$menu/guns/fireSpeed.select_button()
	elif(gun_button == 2):
		$menu/guns/bulletSpeed.select_button()
	pass
func gun_button_pressed():
	if(Input.is_joy_button_pressed(device_num, 0) and (score[player_num][1] > 0)):
		var buttons = $menu/guns.get_children()
		for i in range(buttons.size()):
			if(buttons[i].button_mode == 1):
				buttons[i].button_pressed()
				if((buttons[i] == $menu/guns/reloadSpeed) and (upgrade_stats[2] < 5)):
					score[player_num][1] -= 1
					stats[player_num][2] += reload_upgrade
					upgrade_total[2] += 1
					upgrade_stats[2] += 1
					gun_stats_update()
				elif((buttons[i] == $menu/guns/fireSpeed) and (upgrade_stats[3] < 5)):
					score[player_num][1] -= 1
					stats[player_num][3] += fire_upgrade
					upgrade_total[3] += 1
					upgrade_stats[3] += 1
					gun_stats_update()
				elif((buttons[i] == $menu/guns/bulletSpeed) and (upgrade_stats[4] < 5)):
					score[player_num][1] -= 1
					stats[player_num][4] += bullet_upgrade
					upgrade_total[4] += 1
					upgrade_stats[4] += 1
					gun_stats_update()
	pass
func gun_stats_update():
	$menu/guns/reloadSpeed/Label.text = str(stats[player_num][2])
	$menu/guns/fireSpeed/Label.text = str(stats[player_num][3])
	$menu/guns/bulletSpeed/Label.text = str(stats[player_num][4])
	$menu/guns/bulletSpeed/Label2.text = str(score[player_num][1])
	upgrade_points_update()
	pass
func gun_exit():
	if(Input.is_joy_button_pressed(device_num, 1)):
		$menu/guns.hide()
		$menu/gunUI.hide()
		$menu/main.show()
		$menu/UI.show()
		state = 0
	elif(device_num == 4): #鍵盤
		if (Input.is_action_pressed("ui_accept")):
			$menu/guns.hide()
			$menu/gunUI.hide()
			$menu/main.show()
			$menu/UI.show()
			state = 0
	pass
func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "hologram"):
		$menu.show()
	pass # replace with function body

func player_ready():
	emit_signal("upgrade_ready")
	get_node("../../..").player_stats[player_num] = stats[player_num]
	get_node("../../..").player_score[player_num] = score[player_num] 
	get_node("../../../../..").upgrade_stats[player_num] = upgrade_stats
	pass
	
func menu_exit():
	pass
	
func _mouse_click(name):
	print(name)
	if(name == "bodyUpgrade"):
		$menu/main.hide()
		$menu/UI.hide()
		$menu/body.show()
		$menu/bodyUI.show()
		state = 1
	elif(name == "gunUpgrade"):
		$menu/main.hide()
		$menu/UI.hide()
		$menu/guns.show()
		$menu/gunUI.show()
		state = 2
	elif(name == "ready"):
		$menu/main.hide()
		$menu/UI.hide()
		$menu/ready.show()
		player_ready()
	elif(name == "speed"):
		score[player_num][0] -= 1
		stats[player_num][1] += speed_upgrade
		body_stats_update()
	elif(name == "health"):
		score[player_num][0] -= 1
		stats[player_num][0] += health_upgrade
		body_stats_update()
	elif(name == "reloadSpeed"):
		score[player_num][1] -= 1
		stats[player_num][2] += reload_upgrade
		gun_stats_update()
	elif(name == "fireSpeed"):
		score[player_num][1] -= 1
		stats[player_num][3] += fire_upgrade
		gun_stats_update()
	elif(name == "bulletSpeed"):
		score[player_num][1] -= 1
		stats[player_num][4] += bullet_upgrade
		gun_stats_update()
	
func button_connect():
	$menu/main/bodyUpgrade.connect("mouse_click", self, "_mouse_click")
	$menu/main/gunUpgrade.connect("mouse_click", self, "_mouse_click")
	$menu/main/ready.connect("mouse_click", self, "_mouse_click")
	$menu/body/speed.connect("mouse_click", self, "_mouse_click")
	$menu/body/health.connect("mouse_click", self, "_mouse_click")
	$menu/guns/reloadSpeed.connect("mouse_click", self, "_mouse_click")
	$menu/guns/fireSpeed.connect("mouse_click", self, "_mouse_click")
	$menu/guns/bulletSpeed.connect("mouse_click", self, "_mouse_click")
	pass
func upgrade_points_update():
	$menu/body/health/points.frame = upgrade_stats[0]
	$menu/body/speed/points.frame = upgrade_stats[1]
	$menu/guns/reloadSpeed/points.frame = upgrade_stats[2]
	$menu/guns/fireSpeed/points.frame = upgrade_stats[3]
	$menu/guns/bulletSpeed/points.frame = upgrade_stats[4]
	pass
func main_ui_update():
	$menu/UI/kills.text = str(score[player_num][0])
	$menu/UI/deaths.text = str(score[player_num][1])
	pass