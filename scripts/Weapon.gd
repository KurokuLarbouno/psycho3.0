extends Node2D

signal update_bullet

#---------------------------------初始值
var CHARGE_TIME = 1		#填充時間
var PRESS_SHOT_TIME = 0.2	#長按發射時間間隔
var SHOT_TIME = 0.2		#短按發射時間間隔
var SWORD_PRESS_SHOT_TIME = 0.6	#刀子長按發射時間間隔
var SWORD_SHOT_TIME = 0.6		#短按發射時間間隔
var BULLET_AMOUNT = 6	#彈匣數
var BULLET_DMG = 1		#子彈傷害
var BULLET_SPEED = 200	#子彈速度
var BULLET_ACCURACY = 0	#子彈準度
var OWNER_NAME = " "	#擁有者
#---------------------------------FLAG
var state = 0		# 0待機狀態 1射擊狀態 2裝彈狀態
var b_clicked = false	#單次輸入限制
var atk = false			#發動攻擊
#---------------------------------計數器
var bullet_count = 0	#已發彈數
var charge_count = 0	#已過填充時間
var shot_count = 0		#距前次擊發時間
var bullet_tex = ""		#子彈貼圖
#---------------------------------變數
var angle
#---------------------------------signal
signal bullet_shot()
signal bullet_reload()

#---------------------------------sword
var is_sword = false
func _ready():
#	if(get_node("../Init_data").kind=="c1"): bullet_tex = "bullet_c1.png"
#	elif(get_node("../Init_data").kind=="c2"): bullet_tex = "bullet_c2.png"
#	elif(get_node("../Init_data").kind=="c3"): bullet_tex = "bullet_c3.png"
#	elif(get_node("../Init_data").kind=="c4"): bullet_tex = "bullet_c4.png"
#	else: bullet_tex = "bullet.png"
	var player_type = get_node("../").player_type 
	if(player_type == 0): bullet_tex = "bullet_c1.png" 
	elif(player_type == 1): bullet_tex = "bullet_c2.png"
	elif(player_type == 2): bullet_tex = "bullet_c3.png"
	elif(player_type == 3): bullet_tex = "bullet_c4.png"
	shot_count = PRESS_SHOT_TIME
	OWNER_NAME = get_owner().get_name()
	get_node("../hand/gun/shotfrom/sword").set_scale(Vector2(0.001, 0.001))
	get_node("../hand/gun/shotfrom/sword").set_position(get_node("../../player").position)
	pass
func _process(delta):
	#----------------------------------------狀態機
	if(state == 0):
		if not is_sword:
			if(shot_count < SHOT_TIME):
				shot_count += delta
			else:
				shot_count = PRESS_SHOT_TIME
		else:
			if(shot_count < SWORD_SHOT_TIME):
				shot_count += delta
			else:
				shot_count = SWORD_PRESS_SHOT_TIME
		pass
	elif(state == 1):
		if(shot_count >= PRESS_SHOT_TIME):#shot action
			shot_count = 0
			if(bullet_count <= BULLET_AMOUNT):
				bullet_count += 1
				#------------------------生子彈
				emit_signal("bullet_shot")#啟動Player的動畫
				#Input.start_joy_vibration(cur_joy, weak, strong, duration)
				Input.start_joy_vibration(get_parent().input_device, 1, 0, 0.1)
				#get_owner().get_node("sound").play("射擊聲")
				var bullet = preload("res://scene/bullet.tscn").instance()
				bullet.set_position(get_node("../hand/gun/shotfrom").get_global_position())
				bullet.dmg = BULLET_DMG
				bullet.sp = BULLET_SPEED
				bullet.a = angle
				bullet.owner_name = OWNER_NAME
				bullet.bullet_tex = bullet_tex
				get_owner().get_parent().get_parent().add_child(bullet)#加到player同層的地方
				state = 0
			if(bullet_count >= BULLET_AMOUNT):
				charge()#重新填裝
			if is_sword:
				state = 0
				pass
		else:
			shot_count += delta
	elif(state == 2):
		if(charge_count >= CHARGE_TIME):
			shot_count = PRESS_SHOT_TIME
			bullet_count = 0
			charge_count = 0
			state = 0
			emit_signal("bullet_reload")
		else:
			charge_count += delta
	elif(state == 3):
		#if(!atk):#shot action
		if(shot_count >= SWORD_PRESS_SHOT_TIME):#shot action
			shot_count = 0
			atk = true

			get_node("../hand/gun/shotfrom/sword").set_position(get_node("../../player/hand/gun/shotfrom").position*0.05)
			get_node("../hand/gun/shotfrom/sword").set_scale(Vector2(3, 3))
			state = 0
			get_node("../animation").play("sword_attack")
			$Timer.set_wait_time(0.1)
			$Timer.start()
		else:
			shot_count += delta
		pass
	else:
		charge_count = 0
		state = 0
		print("Weapon State Error! Back to Idle")
sync func fire(fire_angle, pos):#擊發，需要同時執行
	set_position(pos)
	if(state == 0): 
		
		if is_sword:
			state = 3
			angle = fire_angle
		else:
			state = 1
			angle = fire_angle
		pass
	pass
sync func release():
	if(state == 1):
		state = 0
	if(state == 3):
		state = 0
	pass
sync func charge():
	if not is_sword:
		state = 2#重新填裝
		$sound.play()
	pass
func change_weapon(var_is_sword):
	is_sword = var_is_sword
	pass

func _on_sword_area_entered(area):
	if atk :
		#print(area.get_name())
		if area.get_name() == "swordcollision":
			if get_node(str(area.get_path())+"/../").get_name() != OWNER_NAME:
				get_node(str(area.get_path())+"/../").hurt(BULLET_DMG*2,get_node("../").player_num)
			pass
		elif area.get_name() == "bullet":
			get_node(str(area.get_path())).sp *= -1
			get_node(str(area.get_path())).owner_name = OWNER_NAME
			pass
	pass # replace with function body

func _on_Timer_timeout():
	atk = false
	get_node("../hand/gun/shotfrom/sword").set_scale(Vector2(0.001, 0.001))
	get_node("../hand/gun/shotfrom/sword").set_position(get_node("../../player").position)
	pass # replace with function body
