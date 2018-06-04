extends AStar

var width
var height

const TYPE_WEIGHTS = [4, 3, 1]

func get_id(x, y):
	return x + y * (width + 1)

# Works on the midpoints of the grid. Rotates anti-clockwise 45 degrees

func init(width, height):
	self.width = width
	self.height = height
	
	for y in range(0, height + 1):
		for x in range(0, width + 1):
			var x_pos = x + 0.5 if y % 2 == 0 else x
			var y_pos = y if x % 2 == 0 else y + 0.5
			add_point(get_id(x, y), Vector3(x + 0.5, y + 0.5, 0))

	for y in range(1, height):
		for x in range(1, width):
			for i in range(-1, 1):
				for j in range(-1, 1):
					if i == 0 and j == 0:
						continue
					connect_points(get_id(x + i, y + j), get_id(x, y))

func add_tile(x, y, tile):
	var edge_types = tile.edge_types()
	set_point_weight_scale(get_id(x + 0, y + 0), TYPE_WEIGHTS[edge_types[0]])
	set_point_weight_scale(get_id(x + 1, y + 0), TYPE_WEIGHTS[edge_types[1]])
	set_point_weight_scale(get_id(x + 1, y + 1), TYPE_WEIGHTS[edge_types[2]])
	set_point_weight_scale(get_id(x + 0, y + 1), TYPE_WEIGHTS[edge_types[3]])

func find_route(start, end):
	# Find the closest start ID
	var start_id = get_closest_point(Vector3(start.x, start.y, 0))
	var end_id = get_closest_point(Vector3(end.x, end.y, 0))
	
	var path = get_point_path(start_id, end_id)
	var ret = []
	ret.resize(path.size())
	for i in range(0, path.size()):
		var point = path[i]
		ret[i] = Vector2(point.x, point.y)
	
	return ret

func _ready():
	pass