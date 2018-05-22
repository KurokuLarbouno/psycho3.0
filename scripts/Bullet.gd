extends Area2D

var dmg = 1
var sp = 0
var a  = 0
var motion = Vector2()
var t = 0
var owner_name#-----------------------------------儲存發射者名
var bullet_tex = "bullet_c1.png"

func _ready():
	get_node("body/AnimationPlayer").play("cycle")
	get_node("body/Sprite").texture = load("res://image/Character/"+bullet_tex)
func _physics_process(delta):
	motion = Vector2(cos(a)*sp*delta, sin(a)*sp*delta)
	translate(motion)
	t +=1
	if(t>300):
		self.free()
func _on_bullet_body_entered( body ):
	for i in range(body.get_groups().size()):
		if(body.get_groups()[i]=="wall"):
			t=1000#結束子彈
		if(body.get_groups()[i]=="player_group"):
			if(body.get_name() != owner_name):
				t=1000#結束子彈
				body.hurt(dmg,get_node("../Player/"+str(owner_name)).player_num)
	pass
	
func set_owner(var owname):
	owner_name = owname
	pass

