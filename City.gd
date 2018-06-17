extends Area2D

const city_time = 10

var current_time = 0

signal spawn_timer

func _ready():
	set_process(true)

func set_polygons(polygons):
	for polygon in polygons:
		var poly = CollisionPolygon2D.new()
		poly.polygon = polygon
		add_child(poly)
		
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
		emit_signal("spawn_timer", self, current_team)
		current_time -= city_time