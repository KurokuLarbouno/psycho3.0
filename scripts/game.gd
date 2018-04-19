extends Node2D

func _ready():
	pass
func _physics_process(delta):
	_sort_z()
	pass
	
func _sort_z():
	var sprite = get_tree().get_nodes_in_group("sprite")
	for i in range(sprite.size()):
		var pos = sprite[i].get_global_position()
		sprite[i].z_index = pos.y
	pass