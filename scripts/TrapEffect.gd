extends Node2D

signal mirage

var color_time = 0#顏色改變時間計數器
var color_red_flag = false
var color_blue_flag = false

var slow_flag = false
var slow_time = 0

var atk_flag = false
var atk_time = 0

var speed_flag = false
var speed_time = 0

var hide_flag = false
var hide_time = 0

var mirage_flag = false
func _ready():

	pass

func _process(delta):
	color_blue(delta)
	color_red(delta)
	slow_trap(delta)
	atk_trap(delta)
	speed_trap(delta)
	hide_trap(delta)
	mirage()
	pass

func color_blue(delta):
	if color_blue_flag:
		if color_red_flag:
			color_red_flag = false
			color_time = 0
		color_time += delta
		if color_time > 0.5:
			color_blue_flag = false
			color_time = 0
			get_node("../").set_modulate(Color(1.0,1.0,1.0))
		else:
			get_node("../").set_modulate(Color(1.0,1.0,255/(510*color_time)))
	pass
func color_red(delta):
	if color_red_flag:
		if color_blue_flag:
			color_blue_flag = false
			color_time = 0
		color_time += delta
		if color_time > 0.5:
			color_red_flag = false
			color_time = 0
			get_node("../").set_modulate(Color(1.0,1.0,1.0))
		else:
			get_node("../").set_modulate(Color(255/(510*color_time),1.0,1.0))
	pass
func slow_trap(delta):
	if slow_flag:
		if slow_time > 3.0:
			get_node("../").MOTION_SPEED = get_node("../").reg_speed
			slow_flag  = false
			slow_time = 0
		elif slow_time  == 0 :
			get_node("../").MOTION_SPEED = get_node("../").MOTION_SPEED/2
			slow_time  += delta
		else:
			slow_time  += delta
	pass
func atk_trap(delta):
	if atk_flag:
		if atk_time > 10.0:
			get_node("../Weapon").BULLET_DMG = get_node("../").reg_dmg
			atk_flag = false
			atk_time = 0
		elif atk_time == 0 :
			
			get_node("../Weapon").BULLET_DMG *=2
			atk_time += delta
		else:
			atk_time += delta
	pass
func speed_trap(delta):
	if speed_flag:
		if speed_time > 5.0:
			get_node("../").MOTION_SPEED = get_node("../").reg_speed
			speed_flag = false
			speed_time = 0
		elif speed_time == 0 :
			get_node("../").MOTION_SPEED = get_node("../").MOTION_SPEED*1.2
			#get_node("/root/Game/Camera/Camera2D").mirage()
			#if (is_network_master()):
			#	get_node("/root/Game/Camera/Camera2D").mirage_time_control=30
			#	get_node("/root/Game/Camera/Camera2D").mirage_flag=true
			speed_time += delta
		else:
			speed_time += delta
		pass
	pass
func hide_trap(delta):
	if hide_flag:
		hide_time += delta
		if hide_time > 10:
			hide_flag = false
			hide_time = 0
			get_node("../").set_modulate(Color(1.0,1.0,1.0,1.0))
		else:
			get_node("../").set_modulate(Color(1.0,1.0,1.0,0.05))
	pass
func mirage():
	if mirage_flag:
		emit_signal("mirage")
		mirage_flag = false
	pass