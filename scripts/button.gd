extends Node2D

signal lmouse_click()
signal rmouse_click()
signal rdmouse_click()

export(Texture) var normal = load("res://image/StartEnd/buttom1.png")
export(Texture)  var pressed = load("res://image/StartEnd/buttom2.png")
export(Texture)  var focus = load("res://image/StartEnd/host.png")
export var is_ready = false
var button_mode = 0 # 0 = normal; 2 = pressed; 1 = focus
var t = 0
var delay = 20
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	$image.set_texture(normal)
	pass

func _process(delta):
	if(!is_ready):
		if(button_mode == 2):
			t += 1
		if(t > delay):
			select_button()
			t = 0
	pass
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

func _on_Button_pressed():
	if(name == "left"): emit_signal("lmouse_click")
	if(name == "right"): emit_signal("rmouse_click")
	if(name == "ready"): emit_signal("rdmouse_click")
	button_pressed()
	pass

func _on_Button_mouse_entered():
	select_button()
	pass

func _on_Button_mouse_exited():
	deselect_button()
	pass
