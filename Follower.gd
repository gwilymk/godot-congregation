tool

extends Sprite

var last_tick_time = 0
var current_frame_offset = 0
var frame_offset = 0
var is_moving = false
export var network_id = 0

export var speed = 100
export var direction = Vector2(0, 1)
export var is_punching = false
export var frame_time = 60
export var color = Vector3(0.5, 0, 0)

export var player_id = 1

const MIN_DISTANCE = 0.1

var selected = false
var current_path = []

func _from_hsv(h, s, v):
	h %= 360
	var c = v * s
	var h_prime = h / 60.0
	var x = c * (1 - (h_prime - floor(h_prime)))
	
	if 0 <= h_prime && h_prime <= 1:
		return Color(c, x, 0)
	elif 1 <= h_prime && h_prime <= 2:
		return Color(x, c, 0)
	elif 2 <= h_prime && h_prime <= 3:
		return Color(0, c, x)
	elif 3 <= h_prime && h_prime <= 4:
		return Color(x, 0, c)
	else:
		return Color(c, 0, x)

func _get_player_color(player_id):
	var player_colors

	if get_tree().has_meta("player_colors"):
		player_colors = get_tree().get_meta("player_colors")
	else:
		player_colors = {}
		get_tree().set_meta("player_colors", player_colors)
	
	if player_colors.has(player_id):
		return player_colors[player_id]
	
	var color_seed = hash(get_tree().get_meta("random_seed") + player_id)
	var color = _from_hsv(abs(color_seed), 0.8, 0.8)
	player_colors[player_id] = color
	return color

func _get_player_material():
	var player_materials
	if get_tree().has_meta("player_materials"):
		player_materials = get_tree().get_meta("player_materials")
	else:
		player_materials = {}
		get_tree().set_meta("player_materials", player_materials)
	
	if player_materials.has(player_id):
		return player_materials[player_id]
	
	var player_material = material.duplicate()
	var color = _get_player_color(player_id)
	player_material.set_shader_param("color", Vector3(color.r, color.g, color.b))
	return player_material

func _ready():
	set_process(true)
	material = _get_player_material()

	next_frame()

func get_bounds():
	var size = texture.get_size()
	size = Vector2(size.x / hframes, size.y / vframes)
	return Rect2(position - size / 2, size)

func set_selected(is_selected):
	selected = is_selected
	$SelectionArrow.visible = selected

func _process(delta):
	if current_path.size() > 0 and !is_moving:
		goto_location(current_path[0])
		current_path.pop_front()
	last_tick_time += delta * 1000
	if last_tick_time > frame_time:
		next_frame()
		last_tick_time -= frame_time

func _physics_process(delta):
	# Check collisions (only if not moving)
	if !is_moving:
		var direction_to_move = Vector2(0, 0)
		for colliding_with in $CollisionArea.get_overlapping_areas():
			direction_to_move += (position - colliding_with.get_parent().position)

		position += 10 * delta * direction_to_move.normalized()

func follow_path(path):
	current_path = path
	is_moving = false

func goto_location(new_position):
	direction = (new_position - position).normalized()
	var distance = (position - new_position).length()
	if distance < MIN_DISTANCE:
		return
	is_moving = true
	$Tween.remove_all()
	$Tween.interpolate_property(self, "position", position, new_position, distance / speed, Tween.TRANS_LINEAR, 0)
	$Tween.start()

func next_frame():
	var angle = 2 * direction.angle() / PI
	frame_offset = int((round(angle) + 5)) % 4
	
	if not is_punching and not is_moving:
		current_frame_offset = 0
	else:
		current_frame_offset = (current_frame_offset + 1) % 8

	frame = frame_offset * 8 + current_frame_offset
	if is_punching:
		frame += 4 * 8

func on_walk_completed(object, key):
	is_moving = false
