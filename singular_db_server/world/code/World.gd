extends Node

var network = NetworkedMultiplayerENet.new()
var multiplayer_api = MultiplayerAPI.new()

var port = 1910
var max_players = 100

var global_world_state = {}

var connection_ids = {}
var config_pos = {
	1 : {
		"min" : Vector2(-440, -400),
		"max" : Vector2(1410, 1506)
	},
	2: {
		"min" : Vector2(1410, 256 - 700),
		"max" : Vector2(2660 + 600, 1506)
	},
	3: {
		"min" : Vector2(160 - 600, 1506),
		"max" : Vector2(1410, 2765 + 700)
	},
	4: {
		"min" : Vector2(1410, 1506),
		"max" : Vector2(2660 + 600, 2765 + 700)
	}
}

func _ready():
	StartServer()

# Only poll if it can
func _process(_delta):
	# make sure the client only polls when it can
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func _physics_process(delta):
	for key in connection_ids:
		# Loop through all connected region servers
		var personal_world_state = {}
		for player in global_world_state.keys():
			# Check if player is loacted in the outer borders not owned by that server
			if global_world_state[player]["pos"].x > config_pos[key]["min"].x - 450 &&  global_world_state[player]["pos"].x < config_pos[key]["min"].x:
				personal_world_state[player] = global_world_state[player]
				continue
			
			if global_world_state[player]["pos"].x < config_pos[key]["max"].x + 450 && global_world_state[player]["pos"].x > config_pos[key]["max"].x:
				personal_world_state[player] = global_world_state[player]
				continue
				
			if global_world_state[player]["pos"].y > config_pos[key]["min"].y - 450 &&  global_world_state[player]["pos"].y < config_pos[key]["min"].y:
				personal_world_state[player] = global_world_state[player]
				continue
			
			if global_world_state[player]["pos"].y < config_pos[key]["max"].y + 450 && global_world_state[player]["pos"].y > config_pos[key]["max"].y:
				personal_world_state[player] = global_world_state[player]
				continue
				
		rpc_id(connection_ids[key], "receive_db_state", personal_world_state)
	
func StartServer():
	# Create server
	network.create_server(port, 1000)
	set_custom_multiplayer(multiplayer_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Server started")
	
	# Connect network signals
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " connected")
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
		
# -------------- Client to server -------------------------

# Updates the global world state
remote func receive_world_state(world_state):
	global_world_state.merge(world_state, true)

# Forwards player state to correct region
remote func receive_forward_player_state(region_id, player_id, player_state):
	rpc_unreliable_id(connection_ids[region_id], "receive_forward_state", player_id, player_state)

# Remove global world satte
remote func player_disconnected(id):
	global_world_state.erase(id)

# Assign id to a peer id 
remote func notify_id(id):
	connection_ids[id] = custom_multiplayer.get_rpc_sender_id()
