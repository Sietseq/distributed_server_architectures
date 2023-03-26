extends Node2D

func _draw():
	var col1 = Color(1, 0, 0, 0.5)
	var rect1 = Rect2(Vector2(160, 256), Vector2(1250, 1250))
	
	var col2 = Color(0, 1, 0, 0.5)
	var rect2 = Rect2(Vector2(1410, 256), Vector2(1250, 1250))
	
	var col3 = Color(0, 0, 1, 0.5)
	var rect3 = Rect2(Vector2(160, 1506), Vector2(1250, 1250))
	
	var col4 = Color(1, 1, 0, 0.5)
	var rect4 = Rect2(Vector2(1410, 1506), Vector2(1250, 1250))
	
	var center = get_parent().get_node("YSort/Player").global_position
	var radius = 420
	var color = Color(1, 1, 1, 0.5)
	
	
	draw_rect(rect1, col1, false, 10)
	draw_rect(rect2, col2, false, 10)
	draw_rect(rect3, col3, false, 10)
	draw_rect(rect4, col4, false, 10)
	#draw_circle(center, radius, color)
	
func _physics_process(delta):
	update()
