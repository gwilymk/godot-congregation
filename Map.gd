extends Node

export(int) var width
export(int) var height

export var should_show_paths = false

const TILE_SIZE = 128
const Tile = preload("res://Tile.gd")

var tiles = []
var path_finder = preload("res://PathFinder.gd").new()

func _ready():
	tiles.resize(width * height)
	path_finder.init(width, height)
	
	for y in range(0, height):
		for x in range(0, width):
			var tile = create_tile(x, y, randi() % 5, randi() % 3)
			tile.set_greyscale(1)

func tile_id(x, y):
	return x + y * width

func search_route(start, end):
	var route = path_finder.find_route(start / TILE_SIZE, end / TILE_SIZE)
	
	var ret = []
	ret.resize(route.size() + 2)
	ret[0] = start
	ret[-1] = end
	
	for i in range(0, route.size()):
		ret[i + 1] = Vector2(route[i].x * TILE_SIZE, route[i].y * TILE_SIZE)
	
	if should_show_paths:
		$DebugPath.visible = true
		for i in range($DebugPath.get_point_count() - 1, -1, -1):
			$DebugPath.remove_point(i)
		for pos in ret:
			$DebugPath.add_point(pos)
	return ret

func check_edge(x, y, edge_type, edge_id):
	var tile = tiles[tile_id(x, y)]
	if tile.is_base_tile():
		return true
	else:
		return tile.edge_types()[edge_id] == edge_type

func valid_tile(x, y, id, orientation):
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

func create_tile(x, y, id, orientation):
	var tile = Tile.new_tile(id, orientation)
	tile.position = Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2)

	var old_tile = tiles[tile_id(x, y)]
	if old_tile != null:
		remove_child(old_tile)

	add_child(tile)
	tiles[tile_id(x, y)] = tile
	tile.set_greyscale(0)
	
	path_finder.add_tile(x, y, tile)
	return tile