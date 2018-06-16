extends ColorRect

# class member variables go here, for example:
# var a = 2
# var b = "textvar"



func _process(delta):
	rect_size = Vector2(rect_size.x, get_viewport_rect().size.y)
