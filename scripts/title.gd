extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var once = 1
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite/AnimationPlayer").play("cycle")
	pass
func _process(delta):
	if(Input.is_action_pressed("ui_accept") and once):
		once -= 1
		get_node("Sprite/AnimationPlayer").play("camera")
	pass
