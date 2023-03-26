extends KinematicBody2D

export (int) var speed = 400

var player_state
var velocity = Vector2()
var direction = Vector2()
var lastDirection = Vector2()

var send_counter = 0

func _ready():
	get_node("AnimationPlayer").play("Idle")

func get_input():
	# changes velocity
	velocity = Vector2()
	direction = Vector2()
	
	# moves right
	if Input.is_action_pressed('right'):
		direction.x = 1
		get_node("Sprite").set_flip_h(false)
	
	# moves left
	if Input.is_action_pressed('left'):
		direction.x = -1
		get_node("Sprite").set_flip_h(true)
	
	# moves down
	if Input.is_action_pressed('down'):
		direction.y = 1
	
	# moves up
	if Input.is_action_pressed('up'):
		direction.y = -1
	
	# Plays the correct animation
	if direction != Vector2(0,0):
		get_node("AnimationPlayer").play("Walk")
	else:
		get_node("AnimationPlayer").play("Idle")
	
	velocity = direction.normalized() * speed

func DefinePlayerState():
	player_state = {"id": ConnectionManager.id, "time" : ConnectionManager.current_server.client_clock, "pos": get_global_position(), "anim": direction}
	ConnectionManager.current_server.send_player_state(player_state)

func _physics_process(_delta):
	# apply the velocity
	send_counter += 1
	if send_counter == 3:
		send_counter = 0
		DefinePlayerState()
	
	get_input()
	velocity = move_and_slide(velocity)


