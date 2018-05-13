extends Node2D

func _ready():
	pass

func start():
	$AnimationPlayer.play("opening")
	
func end():
	$AnimationPlayer.play("ready")