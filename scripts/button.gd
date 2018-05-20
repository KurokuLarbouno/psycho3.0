extends Node2D

signal mouse_click()

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
	#$AnimationPlayer.play("focus")
	button_mode = 1
	pass
func deselect_button():
	$image.set_texture(normal)
	$AnimationPlayer.stop()
	button_mode = 0
	pass
func button_pressed():
	$image.set_texture(pressed)
	$AnimationPlayer.stop()
	button_mode = 2
	pass

func _on_Button_pressed():
	emit_signal("mouse_click", name)
	button_pressed()
	pass

func _on_Button_mouse_entered():
	select_button()
	pass

func _on_Button_mouse_exited():
	deselect_button()
	pass
