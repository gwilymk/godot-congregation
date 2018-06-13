extends Object

var _next_seed
export(int) var initial_seed

func _init(new_seed = null):
	if new_seed == null:
		randomize()
		new_seed = randi()

	initial_seed = hash(new_seed)
	reset()

func reset():
	_next_seed = initial_seed

func next():
	var next_and_seed = rand_seed(_next_seed)
	_next_seed = next_and_seed[1]
	
	return abs(next_and_seed[0])