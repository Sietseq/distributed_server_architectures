extends Node

var network = NetworkedMultiplayerENet.new()
var multiplayer_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1910

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
	rpc_id(1, "notify_id", id)
	
func _on_connection_failed():
	print("Failed to connect")
	

# -------------- Client to server ----------------------------
func request_world_state(peer_id, player_id, world_state):
	rpc_unreliable_id(1, "request_world_state", peer_id, player_id, world_state)

func send_world_state(world_state):
	rpc_unreliable_id(1, "receive_world_state", world_state)

func player_disconnected(id):
	rpc_id(1, "player_disconnected", id)

func forward_player_state(region_id, player_id, player_state):
	rpc_unreliable_id(1, "receive_forward_player_state", region_id, player_id, player_state)
	
# -------------- Server to client ----------------------------
remote func receive_forward_state(player_id, player_state):
	get_parent().receive_forward_state(player_id, player_state)
	
remote func receive_db_state(state):
	get_parent().db_state = state
