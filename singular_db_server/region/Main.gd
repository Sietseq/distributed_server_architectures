extends Node

var server_spawn = preload("res://code/Server.tscn")

var config = {
	1 : {
		"ip" : "18.219.163.66",
		"port" : 1909,
		"min" : Vector2(-440, -400),
		"max" : Vector2(1410, 1506)
	},
	2: {
		"ip" : "3.144.170.191",
		"port" : 1908,
		"min" : Vector2(1410, 256 - 700),
		"max" : Vector2(2660 + 600, 1506)
	},
	3: {
		"ip" : "18.224.4.48",
		"port" : 1907,
		"min" : Vector2(160 - 600, 1506),
		"max" : Vector2(1410, 2765 + 700)
	},
	4: {
		"ip" : "3.14.151.152",
		"port" : 1906,
		"min" : Vector2(1410, 1506),
		"max" : Vector2(2660 + 600, 2765 + 700)
	}
}

func _on_Button_pressed():
	# Get input
	var input = int(get_node("LineEdit").text)
	
	# Remove UI
	get_node("LineEdit").queue_free()
	get_node("Button").queue_free()
	
	# Create new instance
	var new_server = server_spawn.instance()
	new_server.port = config[input]["port"]
	new_server.mininum = config[input]["min"]
	new_server.maxiinum = config[input]["max"]
	new_server.id = input
	add_child(new_server)

func _ready():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	# If there is command argument use that to start the server
	if arguments.has("id"):
		# Get input
		var id = arguments["id"]
		
		# Remove UI
		get_node("LineEdit").queue_free()
		get_node("Button").queue_free()
		
		# Create new instance
		var new_server = server_spawn.instance()
		new_server.port = config[int(id)]["port"]
		new_server.mininum = config[int(id)]["min"]
		new_server.maxiinum = config[int(id)]["max"]
		new_server.id = int(id)
		add_child(new_server)
	
