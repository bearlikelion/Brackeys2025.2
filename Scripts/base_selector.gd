class_name BaseSelector
extends Panel
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
signal base_selected(selected_base: String)

@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/GridContainer

func _ready() -> void:
	if game_manager != null :
		game_manager.base_selector = self
		for button: Button in grid_container.get_children():
			button.pressed.connect(_on_base_selected.bind(button.name))


func _on_base_selected(selected_base: String) -> void:
	base_selected.emit(selected_base)
