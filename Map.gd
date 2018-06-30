extends Node

export(int) var width
export(int) var height


var map_sizes = {
	"Small": Vector2(16,16),
	"Medium": Vector2(32,32),
	"Large": Vector2(64,64)
}

export var should_show_paths = false

const TILE_SIZE = 128
const Tile = preload("res://Tile.gd")

var tiles = []
var path_finder = preload("res://PathFinder.gd").new()

func _ready():
	var random_source = preload("res://RandomNumberGenerator.gd").new(
	  "tiles" + str(get_tree().get_meta("random_seed")))
	
	var width_and_height = map_sizes[get_tree().get_meta("map_size")]
	width = int(width_and_height.x)
	height = int(width_and_height.y)
	
	tiles.resize(width * height)
	path_finder.init(width, height)
	
	for y in range(0, height):
		for x in range(0, width):
			var tile = create_tile(random_source.next() % 5, random_source.next() % 3, x, y)
			tile.set_greyscale(1)

func tile_id(x, y):
	return x + y * width

func from_tile_id(id):
	var x = id % width
	var y = (id - x) / width
	return [x, y]

func search_route(start, end):
	var route = path_finder.find_route(start / TILE_SIZE, end / TILE_SIZE)

	route[0] = start
	route[-1] = end
	
	for i in range(1, route.size() - 1):
		route[i] = Vector2(route[i].x * TILE_SIZE, route[i].y * TILE_SIZE)
	
	if should_show_paths:
		$DebugPath.visible = true
		for i in range($DebugPath.get_point_count() - 1, -1, -1):
			$DebugPath.remove_point(i)
		for pos in route:
			$DebugPath.add_point(pos)
	return route

func check_edge(x, y, edge_type, edge_id):
	var tile = tiles[tile_id(x, y)]
	if tile.is_base_tile():
		return true
	else:
		return tile.edge_types()[edge_id] == edge_type

func valid_tile(id, orientation, x, y):
	if x < 0 or y < 0 or x >= width or y >= height:
		return false

	if !tiles[tile_id(x, y)].is_base_tile():
		return false

	var edge_types = Tile.new_tile(id, orientation).edge_types()
	if x > 0 && !check_edge(x - 1, y, edge_types[3], 1):
		return false
	if x < width - 1 && !check_edge(x + 1, y, edge_types[1], 3):
		return false
	if y > 0 && !check_edge(x, y - 1, edge_types[0], 2):
		return false
	if y < height - 1 && !check_edge(x, y + 1, edge_types[2], 0):
		return false
	
	return true

func id_in_direction(id, direction):
	if direction == 0 and id >= width:
		return id - width
	elif direction == 1 and (id % width) < width - 1:
		return id + 1
	elif direction == 2 and (id < (width * (width - 1))):
		return id + width
	elif direction == 3 and (id % width != 0):
		return id - 1
	else:
		return -1

# Returns a list of connections containing the given city, or null
# if the city is incomplete.
#
# Connections is an array of 2-length arrays of tile ids, representing the
# connections between the tiles.
func trace_city(id, from_direction, connections, first = true):
	var tile = tiles[id]
	if tile.edge_types()[from_direction] != 2:
		return null

	if !first:
		connections.push_back([id, id_in_direction(id, from_direction)])
	
	for direction in tile.connections(from_direction):
		var next_id = id_in_direction(id, direction)
		if next_id == -1:
			return null
		if [id, next_id] in connections or [next_id, id] in connections:
			continue
		
		if trace_city(next_id, (direction + 2) % 4, connections, false) == null:
			return null
	
	return connections

func check_cities(id):
	# Go out in each direction
	var edge_types = tiles[id].edge_types()
	# Don't want to duplicate cities
	var checked_directions = []

	for direction in range(0, 4):
		if direction in checked_directions:
			continue
		if edge_types[direction] == 2:
			for dir in tiles[id].connections(direction):
				checked_directions.push_back(dir)

			# Start a city trace
			var city = trace_city(id, direction, [])
			if city != null:
				$Cities.new_city(city, TILE_SIZE, width)

func create_tile(id, orientation, x, y):
	var tile = Tile.new_tile(id, orientation)
	tile.position = Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2)

	var old_tile = tiles[tile_id(x, y)]
	if old_tile != null:
		$Tiles.remove_child(old_tile)

	$Tiles.add_child(tile)
	tiles[tile_id(x, y)] = tile
	
	tile.set_greyscale(0)
	check_cities(tile_id(x, y))
	
	var base_tile = tile.is_base_tile()
	if base_tile or x == 0 or !tiles[tile_id(x - 1, y)].is_base_tile():
		path_finder.add_tile(x, y, tile, 3)
	if base_tile or x == width - 1 or !tiles[tile_id(x + 1, y)].is_base_tile():
		path_finder.add_tile(x, y, tile, 1)
	if base_tile or y == 0 or !tiles[tile_id(x, y - 1)].is_base_tile():
		path_finder.add_tile(x, y, tile, 0)
	if base_tile or y == height - 1 or !tiles[tile_id(x, y + 1)].is_base_tile():
		path_finder.add_tile(x, y, tile, 2)
	return tile
	