extends Node

func _ready():
	$GamePlay.connect("new_tile", $GUI/Tile, "_on_new_tile")
	$GUI/Tile.connect("placeTile", $GamePlay, "add_tile_emit")
	$GamePlay.next_tile()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
