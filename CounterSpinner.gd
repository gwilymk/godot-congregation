tool
extends Node2D

const NUMBER_OF_POINTS = 32

export var angle_from = 0
export var angle_to = PI/2
export var color = Color(1,0,0)
export var radius = 20

var angle_from_prev = angle_from
var angle_to_prev = angle_to
var color_prev = color
var radius_prev = radius

func _ready():
	set_process(true)
	
func _physics_process(delta):
	if angle_from_prev != angle_from:
		angle_from_prev = angle_from
		update()
	if angle_to_prev != angle_to:
		angle_to_prev = angle_to
		update()
	if color_prev != color:
		color_prev = color
		update()
	if radius_prev != radius:
		radius_prev = radius
		update()

func _draw():
	var points = PoolVector2Array()
	points.push_back(Vector2(0,0))
	var colors = PoolColorArray([color])
	
	for i in range(NUMBER_OF_POINTS+1):
		var a = angle_from + i * (angle_to - angle_from) / NUMBER_OF_POINTS - PI/2
		points.push_back(Vector2(cos(a)*radius, sin(a)*radius))
	draw_polygon(points, colors)