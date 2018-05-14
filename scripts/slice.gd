extends Node2D

signal finish()
signal start()

func _ready():
	pass

func start():
	$AnimationPlayer.play("opening")
	
func end():
	$AnimationPlayer.play("ready")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finish")
	pass 

func _on_AnimationPlayer_animation_started(anim_name):
	emit_signal("start")
	pass # replace with function body
