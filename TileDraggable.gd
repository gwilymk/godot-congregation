extends Sprite

func _input(event):
	if event is InputEventMouseMotion:
		global_position = event.global_position

func _ready():
	var t = preload("res://Tile.tscn").instance()
	vframes = t.vframes
	hframes = t.hframes
	visible = false