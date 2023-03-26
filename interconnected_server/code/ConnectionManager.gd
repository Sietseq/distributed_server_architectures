extends Node

var clients = {}

onready var file = "user://input.txt"
onready var config = get_parent().get_parent().config
onready var client_instance = preload("res://code/Client.tscn")

var client_ids = {}

func load_file(file_use):
	var f = File.new()
	f.open(file_use, File.READ)
	
	var string = f.get_line()
	
	# If the command run is inputted
	if string == "run":
		get_node("Check").queue_free()
		var id = get_parent().get_parent().id
		
		# Create a client for each server this server has to connect to
		for key in config.keys():
			if key == id:
				continue
			var client = client_instance.instance()
			client.ip = config[key]["ip"]
			client.port = config[key]["port"]
			client.id = key
			add_child(client)
			client_ids[key] = client
		
	f.close()
	return

func send_states(state):
	for key in config.keys():
		if key == get_parent().get_parent().id:
			continue
		
		var personal_world_state = {}
		
		# Send over only the states in the borders to each server
		for player in state.keys():
			if state[player]["pos"].x > config[key]["min"].x - 450 &&  state[player]["pos"].x < config[key]["min"].x:
				personal_world_state[player] = state[player]
				continue
			
			if state[player]["pos"].x < config[key]["max"].x + 450 && state[player]["pos"].x > config[key]["max"].x:
				personal_world_state[player] = state[player]
				continue
				
			if state[player]["pos"].y > config[key]["min"].y - 450 &&  state[player]["pos"].y < config[key]["min"].y:
				personal_world_state[player] = state[player]
				continue
			
			if state[player]["pos"].y < config[key]["max"].y + 450 && state[player]["pos"].y > config[key]["max"].y:
				personal_world_state[player] = state[player]
				continue
		
		client_ids[key].send_state(get_parent().get_parent().id, personal_world_state)
		
func send_forward_state(region_id, player_id, player_state):
	client_ids[region_id].send_forward_state(player_id, player_state)

func _on_Check_timeout():
	load_file(file)
