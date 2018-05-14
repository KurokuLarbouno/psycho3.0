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
#玩家傳入最大生命值
func _set_health(health):
	for i in range(health):
		var heart_sprite = Sprite.new()
		heart_sprite.texture = heart_texture
		if(i < 10):
			heart_sprite.position = Vector2(i*18, 15)
		elif(i < 20):
			heart_sprite.position = Vector2((i-10)*18, 33)
		$heart.add_child(heart_sprite)
	print(str(player_num) + " health setted")
	pass
#玩家傳入最大子彈數
func _set_bullet(bullet_amount):
	for i in range(bullet_amount):
		var bullet_sprite = Sprite.new()
		bullet_sprite.texture = bullet_texture
		bullet_sprite.position = Vector2(i*18, 51)
		$bullet.add_child(bullet_sprite)
	pass
#玩家傳入當前血量
func _update_health(cur_health):
	var health = $heart.get_children()
	for i in range(health.size()):
		health[i].hide()
	for x in range(cur_health):
		health[x].show()
	pass
#玩家傳入當前子彈數
func _update_bullet(cur_bullet):
	var bullet = $bullet.get_children()
	for i in range(bullet.size()):
		bullet[i].hide()
	for x in range(cur_bullet):
		bullet[x].show()
	pass
#設定玩家代號圖
func set_player_id():
	if(player_num == 1):
		#$player_id.texture = player1_icon
		$ID.text = "Player1"
	elif(player_num == 2):
		#$player_id.texture = player2_icon
		$ID.text = "Player2"
	elif(player_num == 3):
		#$player_id.texture = player3_icon
		$ID.text = "Player3"
	elif(player_num == 4):
		#$player_id.texture = player4_icon
		$ID.text = "Player4"
	pass
func connect_player(obj):
	obj.connect("update_health", self,"_update_health")
	obj.connect("update_bullet", self, "_update_bullet")
	obj.connect("set_health", self, "_set_health")
	obj.connect("set_bullet", self, "_set_bullet")
	pass