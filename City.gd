extends Area2D

const city_time = 10

var current_time = 0

signal spawn_timer

func _ready():
	collision_layer = 0
	collision_mask = 1
	set_process(true)

func set_polygon(polygon):
	poly = CollisionPolygon2D.new()
	poly.polygon = polygon
	add_child(poly)

func _physics_process(delta):
	var followers = get_overlapping_areas()
	if followers.length() == 0:
		current_time = clamp(current_time - delta, 0, city_time)
		return

	var current_team = followers[0].get_parent().player_id
	for follower in followers:
		if follower.get_parent().player_id != current_team:
			current_time = clamp(current_time - delta, 0, city_time)
			return

	current_time += delta
	
	if current_time >= city_time:
		emit_signal("spawn_timer", self, current_team)
		current_time -= city_time