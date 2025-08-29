class_name BaseSelector
extends Panel

signal base_selected(selected_base: String)
signal bases_hidden()

var lerp_visible: bool = false
var lerp_invisible: bool = false

@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer/GridContainer
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	if game_manager != null :
		game_manager.base_selector = self
		for button: Button in grid_container.get_children():
			button.pressed.connect(_on_base_selected.bind(button.name))


func _process(delta: float) -> void:
	if lerp_visible:
		modulate.a = lerp(modulate.a, 1.0, 1.5 * delta)
		if modulate.a == 1.0:
			lerp_visible = false

	if lerp_invisible:
		modulate.a = lerp(modulate.a, 0.0, 1.5 * delta)
		if modulate.a < 0.1:
			lerp_invisible = false
			bases_hidden.emit()
			hide()

func _on_base_selected(selected_base: String) -> void:
	disable_buttons(true)
	base_selected.emit(selected_base)


func show_bases() -> void:
	Utils.shuffle_buttons(grid_container)
	disable_buttons(false)
	lerp_visible = true
	modulate.a = 0.0
	show()


func hide_bases() -> void:
	lerp_visible = false
	lerp_invisible = true


func disable_buttons(is_disabled: bool) -> void:
	for button: Button in grid_container.get_children():
		button.disabled = is_disabled
