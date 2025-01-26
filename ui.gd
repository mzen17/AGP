extends CanvasLayer


func get_action() -> String:
	# retrieve + wipe
	var txt = $CodeEdit.text
	$CodeEdit.text = ""
	return txt
	
func append_action_to_button(action):
	$Button.connect("pressed", action)
