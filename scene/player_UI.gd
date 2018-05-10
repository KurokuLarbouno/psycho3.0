extends Node2D


var player_num
var player_type
var bullet_amount
var health

var player1_icon = load("res://image/cursor.png")
var player2_icon = load("res://image/cursor.png")
var player3_icon = load("res://image/cursor.png")
var player4_icon = load("res://image/cursor.png")

var heart_texture = load("res://image/Character/heart1.png")
var bullet_texture = load("res://image/Character/bullet_ui.png")

func _ready():
	#設定玩家編號圖
	set_player_id()
	#set_heart()
	#set_bullet()
	pass

func _process(delta):

	pass

func set_heart():
	for i in range(health):
		var heart_sprite = Sprite.new()
		heart_sprite.texture = heart_texture
		heart_sprite.x = i*18
		$bullet.add_child(heart_sprite)
	pass
func set_bullet():
	for i in range(bullet_amount):
		var bullet_sprite = Sprite.new()
		bullet_sprite.texture = bullet_texture
		bullet_sprite.x = i*18
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