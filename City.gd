extends Area2D

const city_time = 10

var current_time = 0
var tile_centres = []

var direction_to_spawn = 0

signal add_follower

func _ready():
	set_process(true)

func set_polygons(polygons):
	for polygon in polygons:
		var poly = CollisionPolygon2D.new()
		poly.polygon = polygon
		add_child(poly)
		
		var centre = Vector2(0.0, 0.0)
		for point in polygon:
			centre += point
		
		centre /= polygon.size()
		tile_centres.push_back(centre)
		
		var visible_polygon = Polygon2D.new()
		visible_polygon.polygon = polygon
		visible_polygon.color = Color(0.9, 0, 0.4, 0.5)
		add_child(visible_polygon)

func _physics_process(delta):
	var followers = get_overlapping_areas()
	if followers.size() == 0:
		current_time = clamp(current_time - delta, 0, city_time)
		return

	var current_team = followers[0].get_parent().player_id
	for follower in followers:
		if follower.get_parent().player_id != current_team:
			current_time = clamp(current_time - delta, 0, city_time)
			return

	current_time += delta
	
	if current_time >= city_time:
		var centres = []
		for point in tile_centres:
			direction_to_spawn += 1
			var angle = Vector2(0.1, 0).rotated(direction_to_spawn)
			emit_signal("add_follower", current_team, point + angle)
		current_time -= city_time