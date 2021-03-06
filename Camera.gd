extends Camera2D

export var SPEED = 400
export var ZOOM_SPEED = 5
export var ZOOM_MIN = 0.5
export var ZOOM_MAX = 2

# Not yet taken from the actual GUI node yet. May in future.
export var GUI_LEFT = 100

var actual_visible = Rect2(0,0,0,0)

onready var origin_position = position
onready var current_position = position

var is_moving = false
var mouse_initial
var initial_position

func _ready():
	set_process(true)

var zooming = 0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			zooming = -1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zooming = 1
		
		if event.button_index == BUTTON_RIGHT:
			mouse_initial = event.position
			initial_position = current_position
	if event is InputEventMouseMotion:
		if event.button_mask & BUTTON_MASK_RIGHT:
			if (mouse_initial - event.position).length() > 10:
				is_moving = true
				current_position = initial_position + (mouse_initial - event.position) * zoom.x
			else:
				is_moving = false
		else:
			is_moving = false
			
func set_size(rect):
	actual_visible = rect
	limit_left = rect.position.x
	limit_top = rect.position.y
	limit_right = rect.position.x + rect.size.x
	limit_bottom = rect.position.x + rect.size.y

func _process(delta):
	origin_position = get_viewport_rect().size / 2
	
	if Input.is_action_pressed("ui_up"):
		current_position += SPEED*delta*Vector2(0,-1)
	if Input.is_action_pressed("ui_down"):
		current_position += SPEED*delta*Vector2(0,1)
	if Input.is_action_pressed("ui_left"):
		current_position += SPEED*delta*Vector2(-1,0)
	if Input.is_action_pressed("ui_right"):
		current_position += SPEED*delta*Vector2(1,0)
		
	limit_left = actual_visible.position.x - GUI_LEFT*zoom.x
	
	zoom += zooming*Vector2(1,1)*ZOOM_SPEED*delta
	zooming = 0
	zoom = Vector2(clamp(zoom.x, ZOOM_MIN, ZOOM_MAX), clamp(zoom.y, ZOOM_MIN, ZOOM_MAX))
	
	position = Vector2(clamp(current_position.x, limit_left + origin_position.x * zoom.x, limit_right - origin_position.x*zoom.x), clamp(current_position.y, limit_top + origin_position.y*zoom.y, limit_bottom - origin_position.y*zoom.y))
	current_position = position