extends Node

var network = NetworkedMultiplayerENet.new()
var multiplayer_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 1909
signal connected

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

var pos = Vector2()
var direction = Vector2()

func _ready():
	connect_to_server()

# Only poll if it can
func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

# Changes client clock
func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
	

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
	
	# Notifies the connectio manager
	emit_signal("connected", self)
	
	# If No id yet get one
	if (ConnectionManager.id == ""):
		rpc_id(1, "get_player_id")
	
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs())
	
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)
	
func _on_connection_failed():
	print("Failed to connect")

# ------------------ Client to Server--------------------------
	
func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())
	
func send_player_state(player_state):
	if str(ConnectionManager.id) != "":
		rpc_unreliable_id(1, "receive_player_state", player_state)

# -------------------Server to Client -----------------------
remote func receive_id(peer_id):
	ConnectionManager.id = peer_id

# Returns the server time
remote func receive_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

# Returns the delta laetency and latency
remote func receive_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() -1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()

remote func receive_world_state(world_state):
	if world_state["time"] - client_clock > 500:
		client_clock = world_state["time"]
	if get_node("/root/World"):
		get_node("/root/World").update_world_state(world_state)
		
remote func change_servers(port, ip):
	ConnectionManager.change_server(port, ip)
