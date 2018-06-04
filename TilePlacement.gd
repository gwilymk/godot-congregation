extends Node

signal placeTile(id, orientation, x, y)
signal newTile(id)

var dragging = false

var tileID = -1
var orientation = 0

func _on_new_tile(id, orientation, inhand):
	if not inhand:
		emit_signal("newTile", id)
	else:
		grab_tile(id, orientation)
	pass

func grab_tile(id, orient):
	$TileDraggable.frame = id
	$TileDraggable.rotation = orient/3 * 2*PI
	$TileDraggable.visible = true
	tileID = id
	orientation = orient

func _input(event):
	if !dragging:
		return false
	if event is InputEventMouseButton:
		if event.button == BUTTON_LEFT:
			dragging = false
			$TileDraggable.visible = false
			emit_signal("placeTile", tileID, orientation, event.position.x, event.position.y)
	if event.is_action_pressed("rotate_left"):
		orientation = orientation + 1 % 3
	if event.is_action_pressed("rotate_right"):
		orientation -= 1
		if orientation > 0:
			orientation = 3
	$TileDraggable.rotation = orientation/3 * 2*PI