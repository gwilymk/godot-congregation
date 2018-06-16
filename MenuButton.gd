extends MenuButton

var selected

func _ready():
	var popup = get_popup()
	popup.add_item("Small")
	popup.add_item("Medium")
	popup.add_item("Large")
	popup.connect("id_pressed", self, "on_item_selected")

func on_item_selected(id):
	selected = get_popup().get_item_text(id)
	get_tree().set_meta("map_size", selected)
	text = "Map Size: " + selected