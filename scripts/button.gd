extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(Texture) var normal = load("res://image/StartEnd/buttom1.png")
export(Texture)  var pressed = load("res://image/StartEnd/buttom2.png")
export(Texture)  var focus = load("res://image/StartEnd/host.png")

var button_mode = 0 # 0 = normal; 2 = pressed; 1 = focus

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$image.set_texture(normal)
	pass

#func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	#pass
func select_button():
	$image.set_texture(focus)
	button_mode = 1
	pass
func deselect_button():
	$image.set_texture(normal)
	button_mode = 0
	pass
func button_pressed():
	$image.set_texture(pressed)
	button_mode = 2
	pass