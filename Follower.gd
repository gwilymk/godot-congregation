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

const MIN_DISTANCE = 0.1

var selected = false
var current_path = []

func _ready():
	set_process(true)
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
