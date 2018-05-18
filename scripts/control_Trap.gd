extends Node2D
var generate_points_num = []
var Trap_spwan_num = 0
var player_body = {}
var color_time = [0,0,0,0]#顏色改變時間計數器
var color_red_flag = [0,0,0,0]
var color_blue_flag = [0,0,0,0]

var slow_flag = [0,0,0,0]
var slow_time = [0,0,0,0]
func _ready():
	#player_body[0]
	pass

func _process(delta):
	if player_body[0] != null:
		trap_effect(delta)
		pass
	pass
func init(body,player_num):
	player_body[player_num] = body
	pass
func trap_effect(delta):
	color_blue(delta)
	color_red(delta)
	slow_trap(delta)
	pass
func color_blue(delta):
	for i in range(4):
		if color_blue_flag[i]:
			if color_red_flag[i]:
				color_red_flag[i] = 0
				color_time[i] = 0
			color_time[i] += delta
			if color_time[i] > 0.5:
				color_blue_flag[i] = 0
				color_time[i] = 0
				player_body[i].set_modulate(Color(1.0,1.0,1.0))
			else:
				player_body[i].set_modulate(Color(1.0,1.0,255/(510*color_time[i])))
	pass
func color_red(delta):
	for i in range(4):
		if color_red_flag[i]:
			if color_blue_flag[i]:
				color_blue_flag[i] = 0
				color_time[i] = 0
			color_time[i] += delta
			if color_time[i] > 0.5:
				color_red_flag[i] = 0
				color_time[i] = 0
				player_body[i].set_modulate(Color(1.0,1.0,1.0))
			else:
				player_body[i].set_modulate(Color(255/(510*color_time[i]),1.0,1.0))
	pass
func slow_trap(delta):
	for i in range(4):
		if slow_flag[i]:
			if slow_time[i] > 3.0:
				player_body[i].MOTION_SPEED = player_body[i].reg_speed
				slow_flag[i]  = 0
				slow_time[i]  = 0
			elif slow_time[i]  == 0 :
				player_body[i].MOTION_SPEED = player_body[i].MOTION_SPEED/2
				slow_time[i]  += delta
			else:
				slow_time[i]  += delta
	pass
