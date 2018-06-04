tool
extends Sprite

signal tileClicked(id)

var tileID = -1

func _ready():
	var t = preload("res://Tile.tscn")
	region_rect = Rect2(Vector2(0,0), t.tile_size())
	vframes = t.vframes
	hframes = t.hframes
	visible = false

func set_tile(id):
	if id < 0:
		visible = false
	else:
		frame = id
		tileID = id
		visible = true
		
func _input(event):
	if !visible:
		return
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button == BUTTON_LEFT:
			if get_rect().has_point(event.position):
				emit_signal("tileClicked", frame)
				visible = false

func get_rect():
	return Rect2(position - region_rect.size/2, region_rect.size)