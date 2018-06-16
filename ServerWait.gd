extends Control

func _ready():
	var tree = get_tree()
	tree.connect("network_peer_connected", self, "new_peer")
	new_peer(tree.get_meta("network_peer").get_unique_id())
	
	if tree.is_network_server():
		$StartGameButton.visible = true

sync func do_start_game(random_seed, mapsize):
	print(mapsize)
	get_tree().set_meta("random_seed", random_seed)
	get_tree().change_scene("res://Game.tscn")

func start_game():
	get_tree().set_refuse_new_network_connections(true)
	randomize()
	
	rpc("do_start_game", randi(), get_tree().get_meta("map_size"))

func new_peer(id):
	$PlayersConnected.add_item("Player: " + str(id))
