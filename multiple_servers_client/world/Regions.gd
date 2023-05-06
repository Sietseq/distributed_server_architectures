extends Node2D

# Debugging tool

func _draw():
	var col1 = Color8(150, 190, 170, 127)
	var rect1 = Rect2(Vector2(160, 256), Vector2(1250, 1250))
	var rect2 = Rect2(Vector2(1410, 256), Vector2(1250, 1250))
	var rect3 = Rect2(Vector2(160, 1506), Vector2(1250, 1250))
	var rect4 = Rect2(Vector2(1410, 1506), Vector2(1250, 1250))
	
	var center = get_parent().get_node("YSort/Player").global_position
	var radius = 420
	var color = Color(1, 1, 1, 0.5)
	
	
	draw_rect(rect1, col1, false, 10)
	draw_rect(rect2, col1, false, 10)
	draw_rect(rect3, col1, false, 10)
	draw_rect(rect4, col1, false, 10)
	
func _physics_process(delta):
	update()
