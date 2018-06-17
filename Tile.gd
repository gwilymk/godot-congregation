extends Sprite

const GRASS = 0
const ROAD = 1
const CITY = 2

# Edge types for the tiles. NESW in order
# 0 = grass
# 1 = road
# 2 = city
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

func _ready():
	material = material.duplicate()

func tile_size():
	var s = texture.get_width()/hframes
	return Vector2(s,s)

static func new_tile(id, orientation):
	var new_tile = preload("res://Tile.tscn").instance()
	new_tile.rotation = ((orientation + 4) % 4) * PI / 2
	new_tile.frame = id
	return new_tile

func rotate_array(array, amount):
	if amount == 0:
		return array
	
	amount = array.size() - amount
	
	var ret = []
	ret.resize(array.size())
	for i in range(amount, array.size()):
		ret[i - amount] = array[i]
	for i in range(0, amount):
		ret[i + array.size() - amount] = array[i]
	
	return ret

func edge_types():
	return rotate_array(EDGE_TYPES[frame], int(2 * (rotation / PI)))

## Return all the directions that connect to dir
func connections(dir):
	var rotation_factor = int(2 * (rotation / PI))
	dir = (dir - rotation_factor + 4) % 4
	var connections = CONNECTIVITY[frame]

	var ret = {}
	ret[dir] = true
	# Trace backwards and forwards. Keep iterating through the
	# connections and check if that is in ret. If it is, add it,
	# otherwise skip. Keep going until ret doesn't change size
	var prev_size = 0
	while ret.size() != prev_size:
		prev_size = ret.size()
		# Forwards trace
		for direction in ret.keys():
			if direction != 3:
				ret[connections[direction]] = true
		
		# Backwards trace
		for direction in ret.keys():
			for i in range(0, 3):
				if connections[i] == direction:
					ret[i] = true

	var ret_array = ret.keys()
	for i in range(0, ret_array.size()):
		ret_array[i] = (ret_array[i] + rotation_factor + 4) % 4
	ret_array.sort()

	return ret_array

func has_watchtower():
	return frame in WATCHTOWER_IDS

func is_base_tile():
	return frame in BASE_TILE_IDS

func set_greyscale(amount):
	material.set_shader_param("greyscale", amount)