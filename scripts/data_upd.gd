extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$ChatBox.text = "Welcome to Energy-Chan Stream!\n"

func post_value(v: String) -> void:
	$ChatBox.text += (v + "\n")

func submit_text_input() -> String:
	var tx = $TextInput.text
	post_value("You: " + tx)
	$TextInput.text = ""
	return tx

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
