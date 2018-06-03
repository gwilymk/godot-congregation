extends Node

var box_select_start = Vector2(0, 0)
const SELECTION_RECT_MIN_AREA = 20

func _ready():
	set_process(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_RIGHT:
			move_followers(event.position)
		elif event.is_pressed() and event.button_index == BUTTON_LEFT:
			box_select_start = event.position
		elif not event.is_pressed() and event.button_index == BUTTON_LEFT:
			select_followers(Rect2(box_select_start, event.position - box_select_start).abs())
	elif event is InputEventMouseMotion:
		if event.button_mask & BUTTON_MASK_LEFT:
			var new_rect = Rect2(box_select_start, event.position - box_select_start).abs()
			if new_rect.get_area() > SELECTION_RECT_MIN_AREA:
				$SelectionBox.rect_position = new_rect.position
				$SelectionBox.rect_size = new_rect.size
				$SelectionBox.visible = true

func select_followers(rect):
	for follower in $Followers.get_children():
		follower.set_selected(follower.get_bounds().intersects(rect))
	$SelectionBox.visible = false

func move_followers(location):
	for follower in $Followers.get_children():
		if follower.selected:
			follower.goto_location(location)

func _process(delta):
	pass
