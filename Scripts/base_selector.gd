class_name BaseSelector
extends Panel

signal base_selected(selected_base: String)

@onready var grid_container: GridContainer = $VBoxContainer/GridContainer

func _ready() -> void:
	for button: Button in grid_container.get_children():
		button.pressed.connect(_on_base_selected.bind(button.name))


func _on_base_selected(selected_base: String) -> void:
	base_selected.emit(selected_base)
