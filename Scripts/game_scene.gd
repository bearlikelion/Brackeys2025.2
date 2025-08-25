extends Node3D

var fear: int = 0
var total: int = 0
var score: int = 0
var dice_rolled: int = 0
var dice_to_roll: int = 0
var biscuits_baked: int = 0

var cracked_biscuit: bool = false
var enchanted_biscuit: bool = true

var type: String
var filling: String
var topping: String
var decoration: String
var filling_score: int = 0

@onready var dice_well: DiceWell = $DiceWell

@onready var type_label: Label = %TypeLabel
@onready var topping_label: Label = %ToppingLabel
@onready var filling_label: Label = %FillingLabel

@onready var score_label: Label = %ScoreLabel
@onready var dice_amount: Label = %DiceAmount
@onready var fear_label: Label = %FearLabel

@onready var mutators_bar: VBoxContainer = %MutatorsBar
@onready var chat_instructions: ChatInstructions = %ChatInstructions
@onready var base_selector: BaseSelector = %BaseSelector
@onready var toppings_selector: ToppingsSelector = %ToppingsSelector


func _ready() -> void:
	dice_well.roll_result.connect(_on_roll_result)
	chat_instructions.instructions_done.connect(_on_instructions_done)
	base_selector.base_selected.connect(_on_base_selected)

	toppings_selector.filling_pressed.connect(_on_topping_pressed)
	toppings_selector.topping_pressed.connect(_on_topping_pressed)
	toppings_selector.decoration_pressed.connect(_on_topping_pressed)
	toppings_selector.toppings_selected.connect(_on_toppings_selected)


func _on_roll_result(dice_face: int) -> void:
	match dice_face:
		1:
			if type != "Shortbread":
				add_fear(1)
		2:
			if type != "Shortbread":
				add_fear(2)
		3:
			add_score(1)
		4:
			add_score(2)
		5:
			add_score(4)
		6:
			add_score(6)


func add_score(amount: int) -> void:
	score += amount
	score_label.text = "SCORE: %s" % str(score)


func add_fear(amount: int) -> void:
	fear += amount
	fear_label.text = "FEAR: %s" % str(fear)


func update_dice_count() -> void:
	dice_amount.text = "DICE TO ROLL: %s" % str(dice_to_roll)


func _on_instructions_done() -> void:
	base_selector.show()


func _on_base_selected(selected_base: String) -> void:
	base_selector.hide()
	type = selected_base

	match type:
		"Shortbread":
			dice_to_roll += 1
		"Heart":
			dice_to_roll += 2
		"Square":
			dice_to_roll += 3
		"Round":
			dice_to_roll += 4
		"Gingerbread":
			dice_to_roll += 5
		"Skull":
			dice_to_roll += 6

	type_label.text = "TYPE: %s" % selected_base
	toppings_selector.show()
	update_dice_count()


func _on_toppings_selected(_filling: String, _topping: String, _decoration: String) -> void:
	toppings_selector.hide()

	if _filling != "":
		filling = _filling

	if _topping != "":
		topping = _topping

	if _decoration != "":
		decoration = _decoration

	print("NOW ROLL YOUR LUCK | DICE %s" % dice_to_roll)
	roll_dice()


func roll_dice() -> void:
	for dice_i: int in range(dice_to_roll):
		dice_well.roll_die()
		await get_tree().create_timer(0.1).timeout

	dice_to_roll = 0
	update_dice_count()


func _on_topping_pressed(is_toggled: bool) -> void:
	if is_toggled:
		dice_to_roll += 1
	else:
		dice_to_roll -= 1

	update_dice_count()
