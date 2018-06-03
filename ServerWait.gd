extends Control

func _ready():
	var tree = get_tree()
	tree.connect("network_peer_connected", self, "new_peer")
	new_peer(tree.get_meta("network_peer").get_unique_id())
	
	if tree.is_network_server():
		$StartGameButton.visible = true

sync func do_start_game():
	get_tree().change_scene("res://GamePlay.tscn")

func start_game():
	get_tree().set_refuse_new_network_connections(true)
	
	rpc("do_start_game")

func new_peer(id):
	$PlayersConnected.add_item("Player: " + str(id))
