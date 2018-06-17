extends Node2D

const SQUARE_EDGES = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]

func has_tile_in_direction(id, city, direction, width):
	if direction == 0:
		return (id - width) in city
	elif direction == 1:
		return (id + 1) in city
	elif direction == 2:
		return (id + width) in city
	elif direction == 3:
		return (id - 1) in city

func tile_corner(id, width, tile_size):
	var x = id % width
	var y = (id - x) / width
	
	return Vector2(x, y) * tile_size

func add_direction_coordinates(direction, tile_corner, tile_size):
	var ret = PoolVector2Array()
	ret.push_back(tile_corner + SQUARE_EDGES[direction] * tile_size)
	ret.push_back(tile_corner + SQUARE_EDGES[(direction + 1) % 4] * tile_size)
	return ret

func new_city(city, tile_size, map_width):
	# Need to somehow create the city object from this...
	var new_city = preload("res://City.tscn").instance()
	var polygons = []
	
	for tile in city:
		var tile_corner = tile_corner(tile, map_width, tile_size)
		for direction in range(0, 4):
			if has_tile_in_direction(tile, city, direction, map_width):
				var polygon = PoolVector2Array()
				polygon.push_back(tile_corner + Vector2(0.5, 0.5) * tile_size)
				polygon.append_array(add_direction_coordinates(direction, tile_corner, tile_size))
				print(polygon)

				polygons.push_back(polygon)

	new_city.set_polygons(polygons)
	add_child(new_city)