extends Sprite

var last_tick_time = 0
var current_frame_offset = 0
var frame_offset = 0

export var direction = Vector2(0, 1)
export var is_punching = false
export var frame_time = 60

func _ready():
	set_process(true)
	next_frame()

func _process(delta):
	last_tick_time += delta * 1000
	if last_tick_time > frame_time:
		next_frame()
		last_tick_time -= frame_time

func next_frame():
	var angle = 2 * direction.angle() / PI
	frame_offset = int((round(angle) + 1)) % 4
	
	current_frame_offset = (current_frame_offset + 1) % 8
	frame = frame_offset * 8 + current_frame_offset
	if is_punching:
		frame += 4 * 8