extends Node2D
var device_num
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var pname 
var button = 1
func _ready():
	$player.text = pname
	$buttons/ready.grab_focus()
	pass

func _process(delta):
	button_selet()
	pass
func button_selet():
	#left
	if(Input.get_joy_axis(device_num,0) < -0.3): 
		button -= 1
		print("left")
	#right
	if(Input.get_joy_axis(device_num,0) > 0.3):
		button += 1
		print("right")
	#up
	if(Input.get_joy_axis(device_num,1) < -0.3):
		button -= 1
		print("up")
	#down
	if(Input.get_joy_axis(device_num,1) > 0.3):
		button +=1 
		print("down")
	pass
func button_focus():
	if(button == 0):
		$buttons/change_character.grab_focus()
	if(button == 1):
		$buttons/ready.grab_focus()
	pass
