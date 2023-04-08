extends Node

var server_spawn = preload("res://Server.tscn")
var current_server
var destination_server

var id = -1
var send_counter = 0

var config = {
	1 : {
		"ip" : "127.0.0.1",
		"port" : 1909,
		"min" : Vector2(-440, -400),
		"max" : Vector2(1410, 1506)
	},
	2: {
		"ip" : "127.0.0.1",
		"port" : 1908,
		"min" : Vector2(1410, 256 - 700),
		"max" : Vector2(2660 + 600, 1506)
	},
	3: {
		"ip" : "127.0.0.1",
		"port" : 1907,
		"min" : Vector2(160 - 600, 1506),
		"max" : Vector2(1410, 2765 + 700)
	},
	4: {
		"ip" : "127.0.0.1",
		"port" : 1906,
		"min" : Vector2(1410, 1506),
		"max" : Vector2(2660 + 600, 2765 + 700)
	}
}

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
	var id = region_of_player(get_node("PositionLogic/Player").global_position)
	
	var server = server_spawn.instance()
	server.name = "main"
	server.ip = config[id]["ip"]
	server.port = config[id]["port"]
	add_child(server)
	current_server = get_node("main")

func _physics_process(delta):
	send_counter += 1
	if send_counter == 3:
		send_counter = 0
		var player_state = {"id": id, "time" : current_server.client_clock, "pos": get_node("PositionLogic/Player").global_position, "anim": get_node("PositionLogic").direction}
		current_server.send_player_state(player_state)

func change_server(port, ip):
	var server = server_spawn.instance()
	server.name = "connecting"
	server.port = port
	server.ip = ip
	server.connect("connected", self, "_on_connected")
	add_child(server)

func _on_connected(node):
	current_server.queue_free()
	node.name = "main"
	current_server = node
