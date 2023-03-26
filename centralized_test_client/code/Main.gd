extends Node

var client_instance = preload("res://code/Client.tscn")

func _ready():
	var arguments = {}
	var clients = 0
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	# If there is no argument set ammount to 25
	if not arguments.has("clients"):
		clients = 25
	else:
		clients = int(arguments["clients"])
	
	# Create the clients
	for i in range(clients):
		var new_server = client_instance.instance()
		add_child(new_server)
