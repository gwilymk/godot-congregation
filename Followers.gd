extends Node

func select_followers(position):
	for follower in get_children():
		follower.set_selected(follower.is_at_position(position))