class_name ToppingsSelector
extends Panel

@export var fillings: ButtonGroup
@export var toppings: ButtonGroup
@export var decorations: ButtonGroup

signal filling_pressed(is_toggled: bool)
signal topping_pressed(is_toggled: bool)
signal decoration_pressed(is_toggled: bool)
signal toppings_selected(filling: String, topping: String, decoration: String)
signal toppings_hidden()

var lerp_visible: bool = false
var lerp_invisible: bool = false

var filling: String
var topping: String
var decoration: String

@onready var bake: Button = %Bake
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var filling_buttons: VBoxContainer = %FillingButtons
@onready var topping_buttons: VBoxContainer = %ToppingButtons
@onready var decoration_buttons: VBoxContainer = %DecorationButtons



func _ready() -> void:
	if game_manager != null :
		game_manager.toppings_selector = self
		game_manager.round_started.connect(_on_round_started)
		bake.pressed.connect(_on_bake_pressed)

		for filling_button: Button in fillings.get_buttons():
			filling_button.toggled.connect(_on_filling_pressed)

		for topping_button: Button in toppings.get_buttons():
			topping_button.toggled.connect(_on_topping_pressed)

		for decoration_button: Button in decorations.get_buttons():
			decoration_button.toggled.connect(_on_decoration_pressed)


func _process(delta: float) -> void:
	if lerp_visible:
		modulate.a = lerp(modulate.a, 1.0, 1.5 * delta)
		if modulate.a == 1.0:
			lerp_visible = false

	if lerp_invisible:
		modulate.a = lerp(modulate.a, 0.0, 1.5 * delta)
		if modulate.a < 0.1:
			lerp_invisible = false
			toppings_hidden.emit()
			hide()


func show_toppings() -> void:
	Utils.shuffle_buttons(filling_buttons)
	Utils.shuffle_buttons(topping_buttons)
	Utils.shuffle_buttons(decoration_buttons)
	lerp_visible = true
	modulate.a = 0.0
	show()


func hide_toppings() -> void:
	lerp_invisible = true
	lerp_visible = false


func _on_filling_pressed(toggled_on: bool) -> void:
	filling_pressed.emit(toggled_on)


func _on_topping_pressed(toggled_on: bool) -> void:
	topping_pressed.emit(toggled_on)


func _on_decoration_pressed(toggled_on: bool) -> void:
	decoration_pressed.emit(toggled_on)


func _on_bake_pressed() -> void:
	var _filling: Button = fillings.get_pressed_button()
	if _filling:
		filling = _filling.name

	var _topping: Button = toppings.get_pressed_button()
	if _topping:
		topping = _topping.name

	var _decoration: Button = decorations.get_pressed_button()
	if _decoration:
		decoration = _decoration.name

	toppings_selected.emit(filling, topping, decoration)


func _on_round_started() -> void:
	filling = ""
	topping = ""
	decoration = ""

	var _filling: Button = fillings.get_pressed_button()
	if _filling:
		_filling.button_pressed = false

	var _topping: Button = toppings.get_pressed_button()
	if _topping:
		_topping.button_pressed = false

	var _decoration: Button = decorations.get_pressed_button()
	if _decoration:
		_decoration.button_pressed = false
