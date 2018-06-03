extends Control

func _ready():
	var tree = get_tree()
	tree.connect("network_peer_connected", self, "new_peer")
	new_peer(tree.get_meta("network_peer").get_unique_id())
	
	if tree.is_network_server():
		$StartGameButton.visible = true

func start_game():
	get_tree().set_refuse_new_network_connections(true)

func new_peer(id):
	$PlayersConnected.add_item("Player: " + str(id))
