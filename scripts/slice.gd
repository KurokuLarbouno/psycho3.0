extends Node2D

signal finish()

func _ready():
	pass

func start():
	$AnimationPlayer.play("opening")
	
func end():
	$AnimationPlayer.play("ready")

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "ready"):
		emit_signal("finish")
	pass 
