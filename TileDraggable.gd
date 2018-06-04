extends Sprite

func _input(event):
	if event is InputEventMouseMotion:
		position = event.position

func _ready():
	var t = preload("res://Tile.tscn").instance()
	region_rect = Rect2(Vector2(0,0), t.tile_size())
	vframes = t.vframes
	hframes = t.hframes
	visible = false