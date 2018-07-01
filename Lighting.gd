extends Node2D

var LightSquares = {}
onready var my_player_id = get_tree().get_meta("network_peer").get_unique_id()
onready var tile_size = get_parent().get_node("Map").TILE_SIZE
onready var map_size = Vector2(get_parent().get_node("Map").width, get_parent().get_node("Map").height)

onready var Map = get_parent().get_node("Map")

export var VIEW = 4
export var WATCHTOWER = 6

func _light_up_area(centre, visibility_range, light_squares):
	var short_visibility = (visibility_range - 1) * (visibility_range - 1)
	var long_visibility = visibility_range * visibility_range
	for x in range(-visibility_range, visibility_range):
		for y in range(-visibility_range, visibility_range):
			var x_diff = centre.x + x 
			var y_diff = centre.y + y
			var pos = centre + Vector2(x,y)
			if x*x + y*y < short_visibility:
				light_squares[pos] = 0
			elif x*x + y*y < long_visibility:
				light_squares[pos] = light_squares[pos] if light_squares.has(pos) else 0.5

func _process(delta):
	#var prevLight = LightSquares
	LightSquares = {}
	var followers = get_parent().get_node("Followers").get_children()
	var handled_ids = {}

	for follower in followers:
		if follower.player_id == my_player_id:
			var posExact = follower.position / tile_size
			var posRound = Vector2(floor(posExact.x), floor(posExact.y))
			var tile_id = Map.tile_id(posRound.x, posRound.y)
			if tile_id == -1 or handled_ids.has(tile_id):
				continue
			else:
				handled_ids[tile_id] = true
			
			var visibleRange
			if Map.tiles[tile_id].has_watchtower():
				visibleRange = WATCHTOWER
			else:
				visibleRange = VIEW
			_light_up_area(posRound, visibleRange, LightSquares)

	update()

func _draw():
	var tile = Vector2(tile_size,tile_size)
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			var pos = Vector2(x, y)
			if LightSquares.has(pos):
				var alpha = LightSquares[pos]
				draw_rect(Rect2(Vector2(x,y) * tile_size, tile), Color(0,0,0,alpha))
			else:
				draw_rect(Rect2(Vector2(x,y) * tile_size, tile), Color(0,0,0))