extends Node2D

var player_spawn = preload("res://world/PlayerTemplate.tscn")

var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100

func spawn_new_player(player_id, spawn_position):
	var new_player = player_spawn.instance()
	new_player.position = spawn_position
	new_player.name = str(player_id)
	get_node("YSort/OtherPlayers").add_child(new_player)
		
func despawn_player(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("YSort/OtherPlayers/" +  str(player_id)).queue_free()

# This function is called to update the buffer
func update_world_state(world_state):
	if world_state["time"] > last_world_state:
		last_world_state = world_state["time"]
		world_state_buffer.append(world_state)
		
func _physics_process(_delta):
	var render_time = Client.client_clock - interpolation_offset
	
	# If there are enough states to interpolate or extrapolota
	if world_state_buffer.size() > 1:
		
		# Tidy up the buffer
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].time:
			world_state_buffer.remove(0)
		
		# If there is a future state interpolate
		if world_state_buffer.size() > 2 :
			var interpolation_factor = float(render_time - world_state_buffer[1]["time"]) / float(world_state_buffer[2]["time"] - world_state_buffer[1]["time"])
			# Loop through players
			for player in world_state_buffer[2].keys():
				# If the key is the timestamp continue to the next
				if str(player) == "time":
					continue
#
				# If the player is not in both world states
				if not world_state_buffer[1].has(player):
					continue
				
				# If the player exists in the map lerp it
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["pos"], world_state_buffer[2][player]["pos"], interpolation_factor)
					var animation_vector = world_state_buffer[2][player]["anim"]
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
				# Else spawn it
				else:
					spawn_new_player(player, world_state_buffer[2][player]["pos"])
			 
			
		# If there is not a future state extrapolate
		elif render_time > world_state_buffer[1].time:
			
			var extrapolation_factor = float(render_time - world_state_buffer[0]["time"]) / float(world_state_buffer[1]["time"] - world_state_buffer[0]["time"]) - 1.00
			
			for player in world_state_buffer[1].keys():
				# If the key is the timestamp continue to the next
				if str(player) == "time":
					continue
				
				# If the player is not in both world states
				if not world_state_buffer[0].has(player):
					continue
				
				# If the player is in the map extrapolate it
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["pos"] - world_state_buffer[0][player]["pos"])
					var new_position = world_state_buffer[1][player]["pos"] + (position_delta * extrapolation_factor)
					var animation_vector = world_state_buffer[1][player]["anim"]
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
