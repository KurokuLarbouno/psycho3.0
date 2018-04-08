extends Camera2D
var player
var player_name
var read = 1#讀取與否
var pass_time = 0
var whirl_shader
var whirl_flag = false#控制角色攻擊力增加
var whirl_time = 0#whirl增加時間計數器
var whirl_time_control = 5#whirl時間控制
var mirage_shader
var mirage_flag = false#控制角色攻擊力增加
var mirage_time = 0#mirage增加時間計數器
var mirage_time_control#mirage時間控制
func _ready():
	whirl_shader = get_node("whirl").get_material()
	mirage_shader = get_node("mirage").get_material()
	
	pass
func _physics_process(delta):
#	#position = player.position
#	if whirl_flag:whirl(delta)
	if mirage_flag:mirage(delta)
	pass
func set_master(id):	#傳入pid(為name)
	player_name = id
	player = get_node("/root/Game/Roof/Player/"+player_name)
	pass
func shake():
	get_node("Anim_Effect").play("shake")

#func whirl():
#	get_node("Anim_Effect").play("whirl")
#
#func mirage():
#	get_node("Anim_Effect").play("mirage")
func whirl(delta):
	whirl_time += (whirl_time_control - whirl_time) * 0.015;
	if(whirl_time >= whirl_time_control-0.05): whirl_time_control = 0;
	if(whirl_time <= 0.003):  whirl_time_control = 2;
	whirl_shader.set_shader_param("rotation",whirl_time)
	
#	if whirl_time > whirl_time_control:
#		whirl_flag = false
#		whirl_time = 0
#		get_node("whirl").hide()
#	elif whirl_time == 0 :
#		get_node("whirl").show()
#		whirl_time += delta
#	else:
#		#if whirl_time <whirl_time_control/2:
#		print(whirl_time)
#		whirl_shader.set_shader_param("rotation",sin(whirl_time/30)*whirl_time)
#		whirl_time += delta*1
#		
	pass
func mirage(delta):
#	mirage_time += (mirage_time_control - mirage_time) * 0.015;
#	if(mirage_time >= mirage_time_control-0.00003): mirage_time_control = 0;
#	if(mirage_time <= 0.00003):  mirage_time_control = 0.01;
#	mirage_shader.set_shader_param("depth",mirage_time)
	
	if mirage_time > mirage_time_control:
		mirage_flag = false
		mirage_time = 0
		get_node("mirage").hide()
	elif mirage_time == 0 :
		get_node("mirage").show()
		mirage_time += delta

	else:
		#0.005 delta
		var vz=0.009#最嚴重
		var c=mirage_time_control*mirage_time_control/16/vz#弧度
		mirage_shader.set_shader_param("depth",(mirage_time-mirage_time_control/2)*(mirage_time-mirage_time_control/2)/-4/c+vz)
		#mirage_shader.set_shader_param("depth",50)
		#算錯，但很辛苦留下來紀念！
		#mirage_shader.set_shader_param("depth",vz+sqrt(c*(mirage_time_control/2+mirage_time)))
		#這也是可運作的-----mirage_shader.set_shader_param("depth",((mirage_time-mirage_time_control/2)*(mirage_time-mirage_time_control/2)+(-45000*vz))/(-45000))
		mirage_time += delta
		#print((mirage_time-mirage_time_control/2)*(mirage_time-mirage_time_control/2)/-4/c+vz)
	pass