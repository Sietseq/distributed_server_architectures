extends KinematicBody2D

func _ready():
	get_node("Sprite").set_modulate(Color(randf(), randf(), randf(), 0.5))
	get_node("AnimationPlayer").play("Idle")

func MovePlayer(new_position, new_direction):
	
	# Animate player
	if new_direction.x == 1:
		get_node("Sprite").set_flip_h(false)
	if new_direction.x == -1:
		get_node("Sprite").set_flip_h(true)
		
	if new_direction != Vector2(0,0):
		get_node("AnimationPlayer").play("Walk")
	else:
		get_node("AnimationPlayer").play("Idle")
	
	if new_position == position:
		return
	else:
		set_position(new_position)
