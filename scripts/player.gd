extends KinematicBody2D

var angle = 0

var player_num = 0 			# 玩家編號
var input_device = 0	# 輸入裝置編號
var health = 20			# 生命值
var MOTION_SPEED = 8000	# 移動速度
var player_type = 0
var motion
var die = false

var player_state = 0 # 0 出生(無敵); 1 一般; 2 死亡; 3 待機(不能控制)

var anim#前
var new_anim#後
var shot_anim#前
var new_shot_anim#後
var fire_anim = false

var c1_img = load("res://image/Character/ctest1_walk.png")
var c2_img = load("res://image/Character/ctest2_walk.png")
var c3_img = load("res://image/Character/ctest3_walk.png")
var c4_img = load("res://image/Character/ctest4_walk.png")

func _ready():
	if(player_type == 0):
		$main.texture = c1_img
	elif(player_type == 1):
		$main.texture = c2_img
	elif(player_type == 2):
		$main.texture = c3_img
	elif(player_type == 3):
		$main.texture = c4_img
	pass

func _process(delta):
	if(player_state == 0):
		#do something
		player_state = 1
	elif(player_state == 1):
		#do something
		player_move(delta)
		play_anim()
		if(die == true):
			player_state = 2
	elif(player_state == 2):
		player_state = 0
	pass
func player_move(delta):
	motion = Vector2()
	if(input_device < 4): #搖桿
		if (Input.get_joy_axis(input_device, 1)<-0.3): # up
			motion += Vector2(0, Input.get_joy_axis(input_device, 1))
		if (Input.get_joy_axis(input_device, 1)> 0.3): #down
			motion += Vector2(0, Input.get_joy_axis(input_device, 1))
		if (Input.get_joy_axis(input_device, 0)<-0.3): #left
			motion += Vector2(Input.get_joy_axis(input_device, 0), 0)
		if (Input.get_joy_axis(input_device, 0)> 0.3): #right
			motion += Vector2(Input.get_joy_axis(input_device, 0), 0)
	elif(input_device == 4): #鍵盤
		if (Input.is_action_pressed("up")):
			motion += Vector2(0, -1)
		if (Input.is_action_pressed("down")):
			motion += Vector2(0, 1)
		if (Input.is_action_pressed("left")):
			motion += Vector2(-1, 0)
		if (Input.is_action_pressed("right")):
			motion += Vector2(1, 0)
	motion = motion.normalized()*MOTION_SPEED*delta
	move_and_slide(motion)
	pass
func play_anim():
	if (new_anim != anim):
		anim = new_anim
		$animation.play(anim)
	if (new_shot_anim != shot_anim):
		shot_anim = new_anim
		$animation.play(shot_anim)
	if(fire_anim):
			$animation.play("gun_attack")
			$sound.playing = true
			fire_anim = false
	if(angle>0): 
		get_node("hand/gun").flip_v = 1
	else: 
		get_node("hand/gun").flip_v = 0
	#get_node("hand").set_rotation_in_degrees(angle+90)
	get_node("hand").rotation = (angle+90)*PI/180
	get_node("hand/gun").z_index = z_index + 1#----------------------------------------------------18/3/5
	if(motion.length()<=0):
		if(abs(angle)>120):
			new_anim = "stop_back"
			get_node("hand/gun").z_index = z_index - 1
		if(angle>60 and angle<121):new_anim = "stop_left"
		if(angle<-60 and angle>-121):new_anim = "stop_right"
		if(abs(angle)<60):new_anim = "stop_front"
	else:
		if(abs(angle)>120):
			new_anim = "walk_back"
			get_node("hand/gun").z_index = z_index - 1
		if(angle>60 and angle<121):new_anim = "walk_left"
		if(angle<-60 and angle>-121):new_anim = "walk_right"
		if(abs(angle)<60):new_anim = "walk_front"
	pass
func respawn():
	pass
func player_die():
	pass
func player_animation():

	pass
