extends Node2D

var min_region = Vector2(160, 256)
var max_region = Vector2(2660, 2765)

var start_pos = Vector2()
var final_pos = Vector2()
var direction = Vector2()

func _ready():
	get_node("Player").global_position = Vector2(rand_range(min_region.x, max_region.x), rand_range(min_region.y, max_region.y))
	start_pos = get_node("Player").global_position 
	final_pos = Vector2(rand_range(min_region.x, max_region.x), rand_range(min_region.y, max_region.y))
	get_node("Destination").global_position = final_pos
	
	randomize()
	if (start_pos < final_pos):
		direction.x = 1
	else:
		direction.x = -1

func _physics_process(delta):
	var dir = start_pos.direction_to(final_pos)
	get_node("Player").global_position += dir * 150 * delta


func _on_Area2D_body_entered(body):
	if body == get_node("Player"):
		start_pos = body.global_position
		final_pos = Vector2(rand_range(min_region.x, max_region.x), rand_range(min_region.y, max_region.y))
		get_node("Area2D").global_position = final_pos
		
		if (start_pos < final_pos):
			direction.x = 1
		else:
			direction.x = -1
