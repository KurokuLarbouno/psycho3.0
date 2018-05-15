extends Button

signal finish()
var button_mode = 0 # 0 = prepaer; 1 = free; 

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
	$Timer.set_wait_time(0.1)
	$Timer.start()
	pass

func _process(delta):
	pass

func _appear():
	button_mode = 0
	$AnimationPlayer.play("appear")
	pass

func _disappear():
	button_mode = 1
	$AnimationPlayer.play("disappear")
	pass

func _chose():
	if(button_mode == 0):
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
	if($AnimationPlayer.is_playing() && button_mode == 0):
		$AnimationPlayer.play("normal")
	pass 

func _on_myButton_pressed():
	_disappear()
	pass 

func _free():
	$AnimationPlayer.play("normal")

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name == "disappear"):
		emit_signal("finish")
	pass # replace with function body

