extends Button

func _ready():
	self.rect_size = $Label.rect_size
	$rect.rect_size.x = $Label.rect_size.x * 1.2
	$rect.rect_position.x = ($Label.rect_size.x-$rect.rect_size.x)/2
	$rect.rect_position.y = ($Label.rect_size.y-$rect.rect_size.y)/2
	$rect.rect_pivot_offset.x = $rect.rect_size.x / 2
	$rect.rect_pivot_offset.y = $rect.rect_size.y / 2
	$rect.modulate = $Label.modulate
	$Label.rect_pivot_offset.x = $Label.rect_size.x / 2
	$Label.rect_pivot_offset.y = $Label.rect_size.y / 2
	$Timer.set_wait_time(1)
	$Timer.start()
	pass

func _process(delta):
	pass

func _appear():
	$AnimationPlayer.play("appear")
	pass

func _disappear():
	$AnimationPlayer.play("disappear")
	pass

func _chose():
	$AnimationPlayer.play("chose")
	pass

func _on_Timer_timeout():
	_appear()
	pass 


func _on_myButton_mouse_entered():
	if(! $AnimationPlayer.is_playing()):
		_chose()
	pass 

func _on_myButton_mouse_exited():
	if($AnimationPlayer.is_playing()):
		$AnimationPlayer.play("normal")
	pass 

func _on_myButton_pressed():
	$AnimationPlayer.play("disappear")
	pass # replace with function body
