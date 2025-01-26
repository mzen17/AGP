extends Node3D

func _on_button_pressed():
	var action = $UI.get_action()
	var words = action.split(" ")
	
	var targetword = words[-1] if words.size() > 0 else ""
	var command = " ".join(words.slice(0, words.size() - 1)) if words.size() > 0 else "" 
	
	$Energy.exec(command, targetword)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UI.append_action_to_button(_on_button_pressed)

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		get_viewport().set_input_as_handled()
		_on_button_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
