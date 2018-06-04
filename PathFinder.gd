extends AStar

var width
var height

const TYPE_WEIGHTS = [4, 3, 1]

func _estimate_cost(from_id, to_id):
	var from_point = get_point_position(from_id)
	var to_point = get_point_position(to_id)
	
	return (to_point - from_point).length() * 2.5

func get_id(x, y):
	return x + y * (2 * width + 1)

# Works on the midpoints of the grid. Rotates anti-clockwise 45 degrees

func init(width, height):
	self.width = width
	self.height = height
	
	for y in range(0, 2 * height + 1):
		for x in range(0, 2 * width + 1):
			if ((x ^ y) & 1) == 1:
				var x_pos = x / 2.0
				var y_pos = y / 2.0
				add_point(get_id(x, y), Vector3(x_pos, y_pos, 0))

	for y in range(0, 2 * height):
		for x in range(0, 2 * width):
				var my_id = get_id(x, y)
				if x % 2 == 0 and y % 2 != 0:
					connect_points(my_id, get_id(x + 1, y + 1))
					connect_points(my_id, get_id(x + 2, y))
					connect_points(my_id, get_id(x - 1, y + 1))
				elif x % 2 != 0 and y % 2 == 0:
					connect_points(my_id, get_id(x - 1, y + 1))
					connect_points(my_id, get_id(x, y + 2))
					connect_points(my_id, get_id(x + 1, y + 1))

func add_tile(x, y, tile):
	var edge_types = tile.edge_types()
	set_point_weight_scale(get_id(2 * x + 1, 2 * y), TYPE_WEIGHTS[edge_types[0]])
	set_point_weight_scale(get_id(2 * x + 2, 2 * y + 1), TYPE_WEIGHTS[edge_types[1]])
	set_point_weight_scale(get_id(2 * x + 1, 2 * y + 2), TYPE_WEIGHTS[edge_types[2]])
	set_point_weight_scale(get_id(2 * x, 2 * y + 1), TYPE_WEIGHTS[edge_types[3]])

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