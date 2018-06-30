extends Node

var box_select_start = Vector2(0, 0)
const SELECTION_RECT_MIN_AREA = 20

const MAX_TICK_DIFFERENCE = 5
const AHEAD_PLANNING = 10

const TICK_TIME = 0.1

var current_tick = 0
var current_tick_time = 0

var commands = {}
var player_tick_positions = {}
var command_index = 0

var next_network_id = 100

var _tile_random_source = preload("res://RandomNumberGenerator.gd").new()

signal new_tile(id, orientation, in_hand)

sync func update_current_tick(tick):
	player_tick_positions[get_tree().get_rpc_sender_id()] = tick

sync func add_command(command, tick, command_index, arguments):
	var current_commands

	if commands.has(tick):
		current_commands = commands[tick]
	else:
		current_commands = []
		commands[tick] = current_commands
	
	var player_id = get_tree().get_rpc_sender_id()
	if player_id == 0: # get_rpc_sender_id returns 0 if it's yourself
		player_id = get_tree().get_meta("network_peer").get_unique_id()
	
	current_commands.push_back({
		command = command,
		arguments = arguments,
		command_index = command_index,
		player_id = player_id,
	})

func place_player_followers(player, index, num_players):
	var starting_seed = get_tree().get_meta("random_seed")
	var unit_start = Vector2(1, 0).rotated(starting_seed + (index / num_players) * 2 * PI)
	var map_size = Vector2($Map.width, $Map.height)
	var follower_location = Vector2(
		map_size.x / 2 + (map_size.x / 3) * unit_start.x,
		map_size.y / 2 + (map_size.y / 3) * unit_start.y) * $Map.TILE_SIZE

	for i in range(0, 4):
		add_follower(player, follower_location)
	
	return follower_location
	

func place_followers():
	var players = get_tree().get_meta("player_ids")
	var player_num = 0
	var ret

	for player in players:
		var location = place_player_followers(player, player_num, players.size())
		if player == get_tree().get_meta("network_peer").get_unique_id():
			# This is me, so want to ensure that the camera focuses on this
			ret = location
		player_num += 1

	return ret

func _ready():
	$Camera.set_size(Rect2(Vector2(0,0), Vector2($Map.width*$Map.TILE_SIZE, $Map.height*$Map.TILE_SIZE)))
	set_process(true)
	
	var my_location = place_followers()
	$Camera.position = my_location
	$Camera.current_position = my_location

func _input(event):
	if event is InputEventMouseButton:
		var pos = _to_local_coords(event.position)
		if not event.is_pressed() and event.button_index == BUTTON_RIGHT:
			if not $Camera.is_moving:
				move_followers(pos)
		elif event.is_pressed() and event.button_index == BUTTON_LEFT:
			box_select_start = pos
		elif not event.is_pressed() and event.button_index == BUTTON_LEFT:
			select_followers(Rect2(box_select_start, pos - box_select_start).abs())
	elif event is InputEventMouseMotion:
		var pos = _to_local_coords(event.position)
		if event.button_mask & BUTTON_MASK_LEFT:
			var new_rect = Rect2(box_select_start, pos - box_select_start).abs()
			if new_rect.get_area() > SELECTION_RECT_MIN_AREA:
				$SelectionBox.rect_position = new_rect.position
				$SelectionBox.rect_size = new_rect.size
				$SelectionBox.visible = true

onready var _initial_viewport = get_viewport()
func _to_local_coords(coord):
	return (coord - _initial_viewport.size/2)*$Camera.zoom.x + $Camera.position

func select_followers(rect):
	var player_id = get_tree().get_meta("network_peer").get_unique_id()
	for follower in $Followers.get_children():
		if follower.player_id != player_id:
			continue
		var intersects = follower.get_bounds().intersects(rect)
		if Input.is_action_pressed("ui_control"):
			if intersects:
				follower.set_selected(!follower.selected)
		else:
			follower.set_selected(intersects)
	$SelectionBox.visible = false

func send_command(command, arguments):
	rpc("add_command", command, current_tick + AHEAD_PLANNING, command_index, arguments)
	command_index += 1

func move_followers(location):
	var follower_id_list = []
	for follower in $Followers.get_children():
		if follower.selected:
			follower_id_list.push_back(follower.network_id)
	
	if follower_id_list.size() > 0:
		send_command("move_followers", {location = location, follower_ids = follower_id_list})

# Slight lag fix, scatter followers slightly
func fiddle_location_offset(num_followers_to_move, id):
	var amount_to_fiddle = Vector2(1, 0) * sqrt(abs((hash(id + 1) % num_followers_to_move) - 1)) * 30
	return amount_to_fiddle.rotated(hash(id))

func do_move_followers(follower_ids, location):
	for follower in $Followers.get_children():
		if follower.network_id in follower_ids:
			var path = $Map.search_route(follower.position,
				location + fiddle_location_offset(follower_ids.size(), follower.network_id))
			follower.follow_path(path)

func add_tile_emit(id, orientation, x, y):
	var localCords = _to_local_coords(Vector2(x,y))
	add_tile(id, orientation, localCords.x, localCords.y)
	

func add_tile(id, orientation, x, y):
	x = int(x / $Map.TILE_SIZE)
	y = int(y / $Map.TILE_SIZE)
	if !$Map.valid_tile(id, orientation, x, y):# or !$Lighting.LightSquares.has(Vector2(x,y)):
		emit_signal("new_tile", id, orientation, true)
	else:
		send_command("add_tile", {
			x = x,
			y = y,
			id = id,
			orientation = orientation
		})

func next_tile():
	var tile_id = _tile_random_source.next() % (32 - 6) + 6
	emit_signal("new_tile", tile_id, 0, false)

func do_add_tile(id, orientation, x, y, player_id):
	var is_me = player_id == get_tree().get_meta("network_peer").get_unique_id()
	if !$Map.valid_tile(id, orientation, x, y):
		if is_me:
			emit_signal("new_tile", id, orientation, true)
	else:
		$Map.create_tile(id, orientation, x, y)
		if is_me:
			next_tile()

class CommandSorter:
	static func sort(a, b):
		if a.command_index == b.command_index:
			print(a.player_id)
			return a.player_id < b.player_id
		else:
			return a.command_index < b.command_index

func run_commands(commands):
	commands.sort_custom(CommandSorter, "sort")
	
	for command in commands:
		match command.command:
			"move_followers":
				do_move_followers(command.arguments.follower_ids, command.arguments.location)
			"add_tile":
				do_add_tile(command.arguments.id, command.arguments.orientation, command.arguments.x, command.arguments.y, command.player_id)
			_:
				print("Unknown command " + str(command.command))

func add_follower(team, location):
	var follower = preload("res://Follower.tscn").instance()
	follower.player_id = team
	follower.position = location
	next_network_id += 1
	follower.network_id = next_network_id
	$Followers.add_child(follower)

func process_tick():
	if commands.has(current_tick):
		var commands_to_run = commands[current_tick]
		if commands_to_run != null:
			run_commands(commands_to_run)
		commands.erase(current_tick)
	current_tick += 1
	rpc("update_current_tick", current_tick)

func _physics_process(delta):
	for id in player_tick_positions:
		if player_tick_positions[id] < current_tick - MAX_TICK_DIFFERENCE:
			print("Player " + str(id) + " is behind!")
			return

	current_tick_time += delta
	
	if current_tick_time > TICK_TIME:
		process_tick()
		current_tick_time -= TICK_TIME
