extends Node

signal placeTile(id, orientation, x, y)
signal newTile(id)

var dragging = false

var tileID = -1
var orientation = 0

func _on_new_tile(id, orientation, inhand):
	print("New tile!")
	if not inhand:
		emit_signal("newTile", id)
	else:
		grab_tile(id, orientation)

func grab_tile(id, orient):
	$TileDraggable.frame = id
	$TileDraggable.rotation = orient * PI/2
	$TileDraggable.visible = true
	dragging = true
	tileID = id
	orientation = orient

func _input(event):
	if !dragging:
		return false
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			dragging = false
			$TileDraggable.visible = false
			emit_signal("placeTile", tileID, orientation, event.position.x, event.position.y)
	if event.is_action_pressed("rotate_left"):
		orientation = (orientation + 1) % 4
	if event.is_action_pressed("rotate_right"):
		orientation = (orientation + 3) % 4
	$TileDraggable.rotation = orientation * PI/2