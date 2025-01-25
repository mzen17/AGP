extends Node

var init = false
var character
var pg_socket
var session
"""
Init is a program that mimicks Javascript.
"""
var socket
var button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# async GET to /new
	$Node.request_start()
	$Node.request_done.connect(_on_data_received)
	button = get_node("UI/Button")
	button.connect("pressed", _on_button_pressed)

func _on_button_pressed():
	var tx = ($UI.submit_text_input())
	$Node.reply_start(tx, session)
	$Node.reply_done.connect(_on_reply_recieved)

func _on_data_received(data):
	print("Received data:", data)
	character = data["char"]
	session = data["KEY"]
	
	$UI.post_value("NAME: " + character["name"])
	$UI.post_value("PERSONALITY: " + character["personality"])
	$UI.post_value("TK: " + character["talkingto"])
	$UI.post_value("-----------------------------")
	
	# Our WebSocketClient instance.
	pg_socket = WebSocketPeer.new()
	
	pg_socket.connect_to_url("wss://8000--main--neural-engine--mzen17.code.starlitex.com" + "/ws/" + data["KEY"] + "/")

	init = true


func _on_reply_recieved(data):
	print("Received data:", data)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if init:
		# Call this in _process or _physics_process. Data transfer and state updates
		# will only happen when calling this function.
		pg_socket.poll()

		# get_ready_state() tells you what state the socket is in.
		var state = pg_socket.get_ready_state()

		# WebSocketPeer.STATE_OPEN means the socket is connected and ready
		# to send and receive data.
		if state == WebSocketPeer.STATE_OPEN:
			while pg_socket.get_available_packet_count():
				var tv = pg_socket.get_packet().get_string_from_utf8()
				print("Got data from server: ", tv)
				$UI.post_value("Energy: " + tv)

		# WebSocketPeer.STATE_CLOSING means the socket is closing.
		# It is important to keep polling for a clean close.
		elif state == WebSocketPeer.STATE_CLOSING:
			pass

		# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
		# It is now safe to stop polling.
		elif state == WebSocketPeer.STATE_CLOSED:
			# The code will be -1 if the disconnection was not properly notified by the remote peer.
			var code = pg_socket.get_close_code()
			print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
			set_process(false) # Stop processing.
