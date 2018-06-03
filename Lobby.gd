extends Control

func _ready():
	pass

func start_as_server():
	if $MapSize.selected == null:
		$MustSelectMapSizeDialog.popup()