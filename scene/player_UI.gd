extends Node2D


var player_num
var player_type

#還沒畫先用隨便的圖代替
var player1_icon = load("res://image/cursor.png")
var player2_icon = load("res://image/cursor.png")
var player3_icon = load("res://image/cursor.png")
var player4_icon = load("res://image/cursor.png")

var heart_texture = load("res://image/Character/heart1.png")
var bullet_texture = load("res://image/Character/bullet_ui.png")

func _ready():
	#設定玩家編號圖
	set_player_id()

	pass

func _process(delta):

	pass

func _set_health(health):
	for i in range(health):
		var heart_sprite = Sprite.new()
		heart_sprite.texture = heart_texture
		if(i < 10):
			heart_sprite.position = Vector2(i*18, 0)
		elif(i < 20):
			heart_sprite.position = Vector2((i-10)*18, 18)
		$bullet.add_child(heart_sprite)
	print(str(player_num) + " health setted")
	pass
func _set_bullet(bullet_amount):
	for i in range(bullet_amount):
		var bullet_sprite = Sprite.new()
		bullet_sprite.texture = bullet_texture
		bullet_sprite.position = Vector2(i*18, 36)
		$bullet.add_child(bullet_sprite)
	pass
func set_player_id():
	if(player_num == 0):
		$player_id.texture = player1_icon
	elif(player_num == 1):
		$player_id.texture = player2_icon
	elif(player_num == 2):
		$player_id.texture = player3_icon
	elif(player_num == 3):
		$player_id.texture = player4_icon
	pass
func connect_player(obj):
	obj.connect("update_health", self,"_update_health")
	obj.connect("update_bullet", self, "_update_bullet")
	obj.connect("set_health", self, "_set_health")
	obj.connect("set_bullet", self, "_set_bullet")
	pass