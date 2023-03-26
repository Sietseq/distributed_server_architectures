extends Node

class_name NPC

var min_region = Vector2(162, 257)
var max_region = Vector2(865, 447)
var time = 0.0
var pos = Vector2()
var direction = Vector2()
var start_pos = Vector2(500, 400)
var final_pos = Vector2(rand_range(min_region.x, max_region.x), rand_range(min_region.y, max_region.y))

var id

func created():
	if (start_pos < final_pos):
		direction.x = 1
	else:
		direction.x = -1
		
func update(delta):
	time += delta * 0.4
	pos = lerp(start_pos, final_pos, time)
	
	if (time >= 1):
		time = 0
		start_pos = pos
		final_pos = Vector2(rand_range(min_region.x, max_region.x), rand_range(min_region.y, max_region.y))
		
		if (start_pos < final_pos):
			direction.x = 1
		else:
			direction.x = -1
