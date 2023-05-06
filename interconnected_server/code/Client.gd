extends Node

var network = NetworkedMultiplayerENet.new()
var multiplayer_api = MultiplayerAPI.new()
var ip = "0"
var port = 0

var id = 0

func _ready():
	connect_to_server()

# Only poll if it can
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server():
	# Startup client
	network.create_client(ip, port)
	set_custom_multiplayer(multiplayer_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	# Connect signals
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	
func _on_connection_succeeded():
	print("Succesfully connected")
	
func _on_connection_failed():
	print("Failed to connect")
	

# -------------- Client to server ----------------------------
func send_state(id, state):
	rpc_unreliable_id(1, "receive_state", id, state)

func send_forward_state(player_id, player_state):
	rpc_unreliable_id(1, "receive_forward_state", player_id, player_state)
