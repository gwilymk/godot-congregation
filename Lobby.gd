extends Control

const SERVER_PORT = 49322
const MAX_PLAYERS = 8

func _ready():
	pass

func start_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	start_wait(peer)

func start_wait(peer):
	var tree = get_tree()
	tree.set_network_peer(peer)
	tree.set_meta("network_peer", peer)

	tree.change_scene("res://ServerWait.tscn")

func start_as_server():
	if $MapSize.selected == null:
		$MustSelectMapSizeDialog.popup()
	else:
		start_server()

func start_as_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(IP.resolve_hostname($JoinServerIP.text), SERVER_PORT)
	start_wait(peer)
