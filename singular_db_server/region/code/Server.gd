extends Node

var network = NetworkedMultiplayerENet.new()
var multiplayer_api = MultiplayerAPI.new()

var port
var max_players = 1000

var player_state_collection = {}
var despawn_world_state = []
var db_state = {}
var world_state

var id = 0
var mininum = Vector2()
var maxiinum = Vector2()

var config
var players_changing = {}

var id_counter = 0
var peer_ids = {}

# Returns true if player is completely in region
func is_area_of_interest_in_region(player_pos: Vector2, radius: float) -> bool:
	if player_pos.x - radius < mininum.x:
		return false
	
	if player_pos.x + radius > maxiinum.x:
		return false
	
	if player_pos.y + radius > maxiinum.y:
		return false
		
	if player_pos.y - radius < mininum.y:
		return false
	
	return true

# Checks what region player is in 
func region_of_player(player_pos: Vector2) -> int:
	for key in config.keys():
		if player_pos.x < config[key]["min"].x:
			continue
		if player_pos.x > config[key]["max"].x:
			continue
		if player_pos.y < config[key]["min"].y:
			continue
		if player_pos.y > config[key]["max"].y:
			continue
		
		return int(key)
	
	return 0

func _ready():
	start_server()
	config = get_parent().config
	get_node("World").id = id

# Only poll if it can
func _process(_delta):
	# make sure the client only polls when it can
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func _physics_process(delta):
	if not player_state_collection.empty():
		# Erase time keys
		world_state = player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("time")
		
		# Send state to the DB 
		get_node("World").send_world_state(world_state)
		
		# Send customized packets
		for player in peer_ids.keys():
			var personal_world_state = {}
			
			# Loop through local world state
			for send_player in world_state.keys():
				# Check if the player is in the area of interest
				if world_state.has(player):
					if (Vector2(world_state[player]["pos"]).distance_to(world_state[send_player]["pos"]) < 450):
						personal_world_state[send_player] = world_state[send_player]
				elif players_changing.has(player):
					if (Vector2(players_changing[player]["state"]["pos"]).distance_to(world_state[send_player]["pos"]) < 450):
						personal_world_state[send_player] = world_state[send_player]
			
			# Loop through state from DB 
			for send_player in db_state.keys():
				# Check if the player is in the area of interest and not already in send satte 
				if world_state.has(player):
					if (personal_world_state.has(send_player) == false): 
						if (Vector2(world_state[player]["pos"]).distance_to(db_state[send_player]["pos"]) < 450):
							personal_world_state[send_player] = db_state[send_player]
				elif players_changing.has(player):
					if (personal_world_state.has(send_player) == false):
						if (Vector2(players_changing[player]["state"]["pos"]).distance_to(db_state[send_player]["pos"]) < 450):
							personal_world_state[send_player] = db_state[send_player]
			
			send_world_state(peer_ids[player], personal_world_state)


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
	
	# Check what the player ID is 
	for key in peer_ids.keys():
		if peer_ids[key] == player_id:
			if (player_state_collection.has(key)):
				player_state_collection.erase(key)

			if players_changing.has(key) == false:
				get_node("World").player_disconnected(key)

			players_changing.erase(key)
			peer_ids.erase(key)

# Checks if user may have been disconnected by seeing if they have updated their position since last timeout
# Godot sometimes does not check this quickly enough.  
func _on_CheckDespawns_timeout():
	for peer in peer_ids.keys():
		if despawn_world_state.has(peer) == false:
			if (player_state_collection.has(peer)):
				player_state_collection.erase(peer)
			
			if players_changing.has(peer) == false:
				get_node("World").player_disconnected(peer)
			
			players_changing.erase(peer)
			peer_ids.erase(peer)
	
	despawn_world_state.clear()

func receive_forward_state(player_id, player_state):
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["time"] < player_state["time"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state

# -------------- Client to server -------------------------

remote func get_player_id():
	var peer_id = custom_multiplayer.get_rpc_sender_id()
	var player_id = str(id) + str(id_counter)
	peer_ids[player_id] = peer_id
	id_counter += 1
	
	rpc_id(peer_id, "receive_id", player_id)

remote func fetch_server_time(client_time):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_server_time", OS.get_system_time_msecs(), client_time)

remote func determine_latency(client_time):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_latency", client_time)
	
remote func receive_player_state(player_state):
	var peer_id = custom_multiplayer.get_rpc_sender_id()
	var player_id = player_state["id"]
	
	# Check if we have the id in record
	if not peer_ids.has(player_id):
		peer_ids[player_id] = peer_id
		
	despawn_world_state.append(player_id)
	
	# If player is already changing servers forward the state
	if players_changing.has(player_id):
		players_changing[player_id]["state"] = player_state
		send_forward_state(players_changing[player_id]["id"], player_id, player_state)
	else:
		# If the player needs to be forwarded
		if id != region_of_player(player_state["pos"]):
			rpc_id(peer_id, "change_servers", config[region_of_player(player_state["pos"])]["port"], config[region_of_player(player_state["pos"])]["ip"])
			players_changing[player_id] = {}
			players_changing[player_id]["id"] = region_of_player(player_state["pos"])
			players_changing[player_id]["state"] = player_state
			send_forward_state(players_changing[player_id]["id"], player_id, player_state)
		
	# Update own player state
	# Checks if this is the newest update we have 
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["time"] < player_state["time"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
	
# -------------- Server to client ----------------------------
func send_world_state(id, world_state):
	world_state["time"] = OS.get_system_time_msecs()
	rpc_unreliable_id(id, "receive_world_state", world_state)
	
func send_forward_state(region_id, player_id, player_state):
	get_node("World").forward_player_state(region_id, player_id, player_state)
