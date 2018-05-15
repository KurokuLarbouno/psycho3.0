extends Node2D

signal finish()
signal start()

func _ready():
	pass

func start():
	$AnimationPlayer.play("ready")
	
func end():
	$AnimationPlayer.play("ready")

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "ready"):
		emit_signal("start")
		$AnimationPlayer.play("opening2")
	pass 

