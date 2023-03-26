extends Node

var server_spawn = preload("res://singletons/Client.tscn")
var current_server
var destination_server

var id = ""

func _ready():
	var server = server_spawn.instance()
	server.name = "main"
	server.port = 1909
	add_child(server)
	current_server = get_node("main")

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
