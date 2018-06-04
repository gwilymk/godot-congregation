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
	
	current_commands.push_back({
		command = command,
		arguments = arguments,
		command_index = command_index,
		player_id = get_tree().get_rpc_sender_id()
	})

func _ready():
	set_process(true)

func _input(event):
	if event is InputEventMouseButton:
		event.position = (event.position - get_viewport().size/2)*$Camera.zoom.x + $Camera.position
		if not event.is_pressed() and event.button_index == BUTTON_RIGHT:
			if not $Camera.is_moving:
				move_followers(event.position)
		elif event.is_pressed() and event.button_index == BUTTON_LEFT:
			box_select_start = event.position
		elif not event.is_pressed() and event.button_index == BUTTON_LEFT:
			select_followers(Rect2(box_select_start, event.position - box_select_start).abs())
	elif event is InputEventMouseMotion:
		event.position = (event.position - get_viewport().size/2)*$Camera.zoom.x + $Camera.position
		if event.button_mask & BUTTON_MASK_LEFT:
			var new_rect = Rect2(box_select_start, event.position - box_select_start).abs()
			if new_rect.get_area() > SELECTION_RECT_MIN_AREA:
				$SelectionBox.rect_position = new_rect.position
				$SelectionBox.rect_size = new_rect.size
				$SelectionBox.visible = true

func select_followers(rect):
	for follower in $Followers.get_children():
		follower.set_selected(follower.get_bounds().intersects(rect))
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

func do_move_followers(follower_ids, location):
	for follower in $Followers.get_children():
		if follower.network_id in follower_ids:
			var path = $Map.search_route(follower.position, location)
			follower.follow_path(path)

func add_tile(id, orientation, x, y):
	send_command("add_tile", {x = x, y = y, id = id, orientation = orientation})

func do_add_tile(id, orientation, x, y):
	$Map.create_tile(id, orientation, x, y)

class CommandSorter:
	static func sort(a, b):
		if a.command_index == b.command_index:
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
				do_add_tile(command.arguments.x, command.arguments.y, command.arguments.id, command.arguments.orientation)
			_:
				print("Unknown command " + str(command.command))

func process_tick():
	if commands.has(current_tick):
		var commands_to_run = commands[current_tick]
		if commands_to_run != null:
			run_commands(commands_to_run)
		commands.erase(current_tick)
	current_tick += 1
	rpc("update_current_tick", current_tick)

func _process(delta):
	for id in player_tick_positions:
		if player_tick_positions[id] < current_tick - MAX_TICK_DIFFERENCE:
			print("Player " + str(id) + " is behind!")
			return

	current_tick_time += delta
	
	if current_tick_time > TICK_TIME:
		process_tick()
		current_tick_time -= TICK_TIME
