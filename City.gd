extends Area2D

const city_time = 10

var current_time = 0
var current_team_color
var tile_centres = []

var direction_to_spawn = 0

var no_team = Color(0.5, 0.5, 0.5)

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

func _draw():
	var color_to_draw = current_team_color
	if color_to_draw == null:
		color_to_draw = no_team
	color_to_draw.a = current_time / city_time / 2
	for centre in tile_centres:
		# draw_circle(centre, 20 * sqrt((current_time / city_time)), color_to_draw)
		draw_sector(centre, 20, 0, 2*PI*sqrt((current_time / city_time)), color_to_draw)

func draw_sector(centre, radius, angle_from, angle_to, color):
	
	var NUMBER_OF_POINTS = 20
	var points = PoolVector2Array()
	points.push_back(centre)
	var colors = PoolColorArray([color])
	
	for i in range(NUMBER_OF_POINTS+1):
		var a = angle_from + i * (angle_to - angle_from) / NUMBER_OF_POINTS - PI/2
		points.push_back(centre + Vector2(cos(a)*radius, sin(a)*radius))
	draw_polygon(points, colors)
	pass

func _physics_process(delta):
	var followers = get_overlapping_areas()
	if followers.size() == 0:
		current_time = clamp(current_time - delta, 0, city_time)
		current_team_color = no_team
		update()
		return

	var current_team = followers[0].get_parent().player_id
	current_team_color = followers[0].get_parent().get_color()
	for follower in followers:
		if follower.get_parent().player_id != current_team:
			current_time = clamp(current_time - delta, 0, city_time)
			update()
			return

	current_time += delta
	
	if current_time >= city_time:
		var centres = []
		for point in tile_centres:
			direction_to_spawn += 1
			var angle = Vector2(0.1, 0).rotated(direction_to_spawn)
			emit_signal("add_follower", current_team, point + angle)
		current_time -= city_time
	update()