extends Node2D
#---------------------------------初始值
var CHARGE_TIME = 1		#填充時間
var PRESS_SHOT_TIME = 1	#長按發射時間間隔
var SHOT_TIME = 0.5		#短按發射時間間隔
var BULLET_AMOUNT = 6	#彈匣數
var BULLET_DMG = 1		#子彈傷害
var BULLET_SPEED = 200	#子彈速度
var BULLET_ACCURACY = 0	#子彈準度
var OWNER_NAME = " "	#擁有者
#---------------------------------FLAG
var state = 0		# 0待機狀態 1射擊狀態 2裝彈狀態
var b_clicked = false	#單次輸入限制
#---------------------------------計數器
var bullet_count = 0	#已發彈數
var charge_count = 0	#已過填充時間
var shot_count = 0		#距前次擊發時間
var bullet_tex = ""		#子彈貼圖
#---------------------------------變數
var angle
#---------------------------------signal
signal bullet_shot()

func _ready():
	if(get_node("../Init_data").kind=="c1"): bullet_tex = "bullet_c1.png"
	elif(get_node("../Init_data").kind=="c2"): bullet_tex = "bullet_c2.png"
	elif(get_node("../Init_data").kind=="c3"): bullet_tex = "bullet_c3.png"
	elif(get_node("../Init_data").kind=="c4"): bullet_tex = "bullet_c4.png"
	else: bullet_tex = "bullet.png"
	shot_count = PRESS_SHOT_TIME
	OWNER_NAME = get_owner().get_name()
	
	pass
func _process(delta):
	#----------------------------------------狀態機
	if(state == 0):
		if(shot_count < SHOT_TIME):
			shot_count += delta
		else:
			shot_count = PRESS_SHOT_TIME
		pass
	if(state == 1):
		if(shot_count >= PRESS_SHOT_TIME):#shot action
			shot_count = 0
			if(bullet_count <= BULLET_AMOUNT):
				bullet_count += 1
				#------------------------生子彈
				emit_signal("bullet_shot")#啟動Player的動畫
				#get_owner().get_node("sound").play("射擊聲")
				var bullet = preload("res://scene/bullet.tscn").instance()
				bullet.set_position(self.get_global_position())
				bullet.dmg = BULLET_DMG
				bullet.sp = BULLET_SPEED
				bullet.a = angle
				bullet.owner_name = OWNER_NAME
				bullet.bullet_tex = bullet_tex
				get_owner().get_parent().add_child(bullet)#加到player同層的地方
				state = 0
			if(bullet_count >= BULLET_AMOUNT):
				charge()#重新填裝
		else:
			shot_count += delta
	if(state == 2):
		if(charge_count >= CHARGE_TIME):
			shot_count = PRESS_SHOT_TIME
			bullet_count = 0
			charge_count = 0
			state = 0
		else:
			charge_count += delta
	if(state != 0 && state != 1 && state != 2):
		charge_count = 0
		state = 0
		print("Weapon State Error! Back to Idle")
sync func fire(fire_angle, pos):#擊發，需要同時執行
	set_position(pos)
	if(state == 0): 
		state = 1
		angle = fire_angle
	pass
sync func release():
	if(state == 1):
		state = 0
	pass
sync func charge():
	state = 2#重新填裝
	pass