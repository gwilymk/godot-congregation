extends Node2D

signal spawn_follower

const SQUARE_EDGES = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]

func tile_corner(id, width, tile_size):
	var x = id % width
	var y = (id - x) / width
	
	return Vector2(x, y) * tile_size

func new_city(city_connections, tile_size, map_width):
	# Need to somehow create the city object from this...
	var new_city = preload("res://City.tscn").instance()
	var polygons = []
	var centres = []
	
	for connection in city_connections:
		var tile_corner0 = tile_corner(connection[0], map_width, tile_size)
		var tile_corner1 = tile_corner(connection[1], map_width, tile_size)
		
		# add a square from centre of first tile to centre of second
		# tile as the diagonal

		# Take the centre of our desired square
		var centre = (tile_corner0 + tile_corner1) / 2 + tile_size * Vector2(1.0, 1.0) / 2
		if centre in centres:
			continue
		centres.push_back(centre)
		
		var polygon = PoolVector2Array([
			centre + tile_size * Vector2(-0.5, 0),
			centre + tile_size * Vector2(0, -0.5),
			centre + tile_size * Vector2( 0.5, 0),
			centre + tile_size * Vector2(0,  0.5),
		])
		polygons.push_back(polygon)

	new_city.set_polygons(polygons)
	add_child(new_city)
	new_city.connect("add_follower", self, "new_follower")

func new_follower(team, location):
	emit_signal("spawn_follower", team, location)