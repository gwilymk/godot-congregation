extends Node2D

var LightSquares = []
onready var my_player_id = get_tree().get_meta("network_peer").get_unique_id()
onready var tile_size = get_parent().get_node("Map").TILE_SIZE
onready var map_size = Vector2(get_parent().get_node("Map").width, get_parent().get_node("Map").height)

export var VIEW = 4

func _process(delta):
	LightSquares = []
	
	var followers = get_parent().get_node("Followers").get_children()
	
	for follower in followers:
		if follower.player_id == my_player_id:
			var posExact = follower.position / tile_size
			var posRound = Vector2(floor(posExact.x), floor(posExact.y))
			var posIn = posExact-posRound
			for x in range(-4,4):
				for y in range(-4,4):
					var xDif = posIn.x + x 
					var yDif = posIn.y + y
					if xDif*xDif + yDif*yDif < VIEW*VIEW:
						LightSquares.push_back(posRound + Vector2(x,y))
						
	update()

func _draw():	
	var tile = Vector2(tile_size,tile_size)
	for x in range(0, map_size.x):
		for y in range(0, map_size.y):
			if LightSquares.has(Vector2(x,y)):
				continue
			draw_rect(Rect2(Vector2(x,y) * tile_size, tile), Color(0,0,0))