extends Sprite

const GRASS = 0
const ROAD = 1
const CITY = 2

# Edge types for the tiles. NESW in order
const EDGE_TYPES = [
	[0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0], [0, 0, 0, 0],
	[0, 0, 0, 0], [0, 2, 0, 0], [1, 1, 0, 1], [1, 1, 1, 1],

	[1, 0, 0, 1], [0, 1, 0, 1], [0, 1, 0, 1], [2, 2, 2, 2],
	[1, 2, 1, 2], [0, 2, 0, 2], [2, 2, 0, 2], [2, 2, 0, 0],

	[2, 1, 1, 2], [2, 0, 0, 2], [2, 1, 1, 2], [2, 0, 2, 0],
	[2, 1, 2, 1], [2, 0, 0, 0], [2, 1, 1, 0], [2, 0, 1, 1],

	[2, 1, 0, 1], [2, 1, 1, 1], [0, 1, 0, 2], [2, 0, 2, 2],
	[1, 1, 0, 0], [0, 1, 0, 1], [0, 0, 1, 0], [0, 0, 0, 0],
]

# Arrays of length three representing the first edge clockwise (numbered from
# 0 in NESW order) this side connects to.
const CONNECTIVITY = [
	[1, 2, 3], [1, 2, 3], [1, 2, 3], [1, 2, 3],
	[1, 2, 3], [2, 1, 3], [1, 3, 2], [1, 2, 3],

	[3, 2, 2], [0, 3, 2], [0, 3, 2], [1, 2, 3],
	[2, 3, 0], [0, 3, 2], [1, 3, 2], [1, 0, 3],
	
	[3, 2, 1], [0, 2, 2], [0, 2, 2], [0, 3, 2],
	[0, 3, 2], [0, 2, 3], [0, 2, 1], [0, 1, 3],
	
	[0, 3, 2], [0, 2, 3], [0, 1, 2], [0, 1, 2],
	[1, 0, 3], [0, 3, 2], [1, 3, 2], [1, 2, 3],
]

# Tile numbers with watchtowers
const WATCHTOWER_IDS = [30, 31]

# Base tiles
const BASE_TILE_IDS = [0, 1, 2, 3, 4]


func tile_size():
	var s = texture.size.x/hframes
	return Vector2(s,s)

static func new_tile(id, orientation):
	var new_tile = preload("res://Tile.tscn").instance()
	new_tile.rotation = orientation * PI / 2
	new_tile.frame = id
	return new_tile

func rotate_array(array, amount):
	if amount == 0:
		return array
	
	var ret = array.duplicate()
	for i in range(amount, array.size()):
		ret[i] = array[i - amount]
	for i in range(0, amount):
		ret[i] = array[i + amount]
	
	return ret

func edge_types():
	return rotate_array(EDGE_TYPES[frame], int(2 * (rotation / PI)))

func has_watchtower():
	return frame in WATCHTOWER_IDS

func is_base_tile():
	return frame in BASE_TILE_IDS

func set_greyscale(amount):
	material.set_shader_param("greyscale", amount)