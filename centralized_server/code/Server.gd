extends Node

var network = NetworkedMultiplayerENet.new()
var multiplayer_api = MultiplayerAPI.new()

var port = 1909
var max_players = 100

var player_state_collection = {}
var world_state

func _ready():
	start_server()

func _process(_delta):
	# make sure the client only polls when it can
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func _physics_process(delta):
	if not player_state_collection.empty():
		world_state = player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("time")
		world_state["time"] = OS.get_system_time_msecs()
		
		send_world_state(world_state)


func start_server():
	# Create server
	network.create_server(port, 1000)
	set_custom_multiplayer(multiplayer_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Server started")
	
	# Connect network signals
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	
func _peer_connected(player_id):
	print("User " + str(player_id) + " connected")
	
func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	
	# Notify all players, player disconnected
	if (player_state_collection.has(player_id)):
		rpc_id(0, "despawn_player", player_id)
		player_state_collection.erase(player_id)
	

# -------------- Client to server -------------------------

remote func fetch_server_time(client_time):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_server_time", OS.get_system_time_msecs(), client_time)

remote func determine_latency(client_time):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_latency", client_time)
	
remote func receive_player_state(player_state):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	
	# Checks if this is the newest update we have
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["time"] < player_state["time"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
	
# -------------- Server to client ----------------------------

func send_world_state(world_state):
	rpc_unreliable_id(0, "receive_world_state", world_state)
