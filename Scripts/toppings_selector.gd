class_name ToppingsSelector
extends Panel

@export var fillings: ButtonGroup
@export var toppings: ButtonGroup
@export var decorations: ButtonGroup

signal filling_pressed(is_toggled: bool)
signal topping_pressed(is_toggled: bool)
signal decoration_pressed(is_toggled: bool)
signal toppings_selected(filling: String, topping: String, decoration: String)

var filling: String
var topping: String
var decoration: String

@onready var bake: Button = %Bake

func _ready() -> void:
	bake.pressed.connect(_on_bake_pressed)

	for filling_button: Button in fillings.get_buttons():
		filling_button.toggled.connect(_on_filling_pressed)

	for topping_button: Button in toppings.get_buttons():
		topping_button.toggled.connect(_on_topping_pressed)

	for decoration_button: Button in decorations.get_buttons():
		decoration_button.toggled.connect(_on_decoration_pressed)


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
