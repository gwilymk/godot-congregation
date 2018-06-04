extends Node

export(int) var width
export(int) var height

const TILE_SIZE = 128

var tiles = []

func _ready():
	tiles.resize(width * height)
	
	for y in range(0, height):
		for x in range(0, width):
			var tile = create_tile(x, y, randi() % 5, randi() % 3)
			tile.set_greyscale(1)

func tile_id(x, y):
	return x + y * width

func create_tile(x, y, id, orientation):
	var tile = preload("res://Tile.tscn").instance()
	tile.position = Vector2(x * TILE_SIZE + TILE_SIZE / 2, y * TILE_SIZE + TILE_SIZE / 2)
	tile.rotation = orientation * PI / 2
	tile.frame = id

	var old_tile = tiles[tile_id(x, y)]
	if old_tile != null:
		remove_child(old_tile)

	add_child(tile)
	tiles[tile_id(x, y)] = tile
	return tile