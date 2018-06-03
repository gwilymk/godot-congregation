extends Control

func _ready():
	var tree = get_tree()
	tree.connect("network_peer_connected", self, "new_peer")
	
	if tree.is_network_server():
		$StartGameButton.visible = true

func start_game():
	pass

func new_peer(id):
	$PlayersConnected.add_item("Player: " + str(id))
