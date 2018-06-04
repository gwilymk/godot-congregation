extends Camera2D

export var SPEED = 100

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_up"):
		position += SPEED*delta*Vector2(0,-1)
	if Input.is_action_pressed("ui_down"):
		position += SPEED*delta*Vector2(0,1)
	if Input.is_action_pressed("ui_left"):
		position += SPEED*delta*Vector2(-1,0)
	if Input.is_action_pressed("ui_right"):
		position += SPEED*delta*Vector2(1,0)