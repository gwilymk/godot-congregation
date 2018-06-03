extends Node

func _ready():
	set_process(true)

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_RIGHT:
			for follower in $Followers.get_children():
				if follower.selected:
					follower.goto_location(event.position)
		elif event.is_pressed() and event.button_index == BUTTON_LEFT:
			$Followers.select_followers(event.position)

func _process(delta):
	pass
