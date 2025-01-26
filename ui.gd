extends CanvasLayer


func get_action() -> String:
	# retrieve + wipe
	var txt = $ActionInput.text
	$ActionInput.text = ""
	return txt

func append_gui_handler(handler):
	$ActionInput.connect("gui_input", handler)

func append_action_to_button(action):
	$Submit.connect("pressed", action)
