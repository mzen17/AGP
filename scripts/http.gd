
extends Node

signal request_done(data)  # Signal to emit when request is done
signal reply_done(data)

func request_start():
	if not $HTTPRequest.request_completed.is_connected(_on_request_completed):
		$HTTPRequest.request_completed.connect(_on_request_completed)

	#url = "https://api.github.com/repos/godotengine/godot/releases/latest"
	var error = $HTTPRequest.request("https://8000--main--neural-engine--mzen17.code.starlitex.com/new")
	
	if error != OK:
		print("HTTP request failed with error code: ", error)
		
func reply_start(message: String, session: String):
	if not $HTTPRequest.request_completed.is_connected(_on_request_completed):
		$HTTPRequest.request_completed.connect(_on_request_completed)
	
	var headers = ["Content-Type: application/json"]
	var data = {"inputstr": message, "session": session}
	var djson = JSON.stringify(data)
	var error = $HTTPRequest.request(
		"https://8000--main--neural-engine--mzen17.code.starlitex.com/conversate/",
		headers, 
		HTTPClient.METHOD_POST, 
		djson
	)
	
	if error != OK:
		print("HTTP request failed with error code: ", error)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		print("Request successful: ")
		emit_signal("request_done", json)
	else:
		print("Failed to parse response.")
		print(response_code)
