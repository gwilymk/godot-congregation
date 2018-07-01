extends Node2D

var LightSquares = {}
onready var my_player_id = get_tree().get_meta("network_peer").get_unique_id()
onready var tile_size = get_parent().get_node("Map").TILE_SIZE
onready var map_size = Vector2(get_parent().get_node("Map").width, get_parent().get_node("Map").height)

onready var Map = get_parent().get_node("Map")

export var VIEW = 4
export var WATCHTOWER = 6

func _process(delta):
	#var prevLight = LightSquares
	LightSquares = {}
	var followers = get_parent().get_node("Followers").get_children()
	var handled_ids = {}

	for follower in followers:
		if follower.player_id == my_player_id:
			var posExact = follower.position / tile_size
			var posRound = Vector2(floor(posExact.x), floor(posExact.y))
			var posIn = posExact-posRound
			var tile_id = Map.tile_id(posRound.x, posRound.y)
			if handled_ids.has(tile_id):
				continue
			else:
				handled_ids[tile_id] = true
			
			var visibleRange
			if Map.tiles[tile_id].has_watchtower():
				visibleRange = WATCHTOWER
			else:
				visibleRange = VIEW
			for x in range(-visibleRange,visibleRange):
				for y in range(-visibleRange,visibleRange):
					var xDif = posIn.x + x 
					var yDif = posIn.y + y
					if xDif*xDif + yDif*yDif < visibleRange*visibleRange:
						LightSquares[posRound + Vector2(x,y)] = true

	update()

func _draw():
	var tile = Vector2(tile_size,tile_size)
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			if LightSquares.has(Vector2(x,y)):
				continue
			draw_rect(Rect2(Vector2(x,y) * tile_size, tile), Color(0,0,0))