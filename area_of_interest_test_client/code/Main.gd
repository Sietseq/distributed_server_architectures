extends Node

var server_spawn = preload("res://code/Client.tscn")

func _ready():
	var arguments = {}
	var clients = 0
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	# Default is 10 test players
	if not arguments.has("clients"):
		clients = 10
	else:
		clients = int(arguments["clients"])
	
	for i in range(clients):
		var new_server = server_spawn.instance()
		add_child(new_server)
