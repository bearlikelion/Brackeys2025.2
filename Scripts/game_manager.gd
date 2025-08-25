class_name GameManager
extends Node3D

signal view_oven()
# signal view_table()
signal fear_increased()
signal fear_decreased()

var fear: int = 0
var total: int = 0
var score: int = 0

var dice_to_roll: int = 0
var biscuits_baked: int = 0

var dice: Array = []

var cracked_biscuit: bool = false
var enchanted_biscuit: bool = true

var bust: bool = false
var type: String
var filling: String
var topping: String
var decoration: String
var filling_score: int = 0

@onready var dice_scorer: Node = $DiceScorer
@onready var dice_well: DiceWell = $DiceWell

@onready var type_label: Label = %TypeLabel
@onready var topping_label: Label = %ToppingLabel
@onready var filling_label: Label = %FillingLabel

@onready var score_label: Label = %ScoreLabel
@onready var dice_amount: Label = %DiceAmount
@onready var fear_label: Label = %FearLabel

@onready var mutators_bar: VBoxContainer = %MutatorsBar
@onready var chat_instructions: ChatInstructions = %ChatInstructions
@onready var base_selector: BaseSelector :
	set(value):
		base_selector = value
		base_selector.base_selected.connect(_on_base_selected)


@onready var toppings_selector: ToppingsSelector:
	set(value):
		toppings_selector = value
		toppings_selector.filling_pressed.connect(_on_topping_pressed)
		toppings_selector.topping_pressed.connect(_on_topping_pressed)
		toppings_selector.decoration_pressed.connect(_on_topping_pressed)
		toppings_selector.toppings_selected.connect(_on_toppings_selected)


func _ready() -> void:
	dice_well.roll_result.connect(_on_roll_result)
	dice_well.roll_finished.connect(_on_roll_finished)
	chat_instructions.instructions_done.connect(_on_instructions_done)





func _input(event: InputEvent) -> void:
	if event.is_action_pressed("roll_new") and OS.has_feature("debug"):
		base_selector.show()


func _on_roll_result(dice_face: int, dice_type: String, dice_name: String) -> void:
	if not bust:
		dice_scorer.score_die(dice_type, dice_name, dice_face)


func add_score(amount: int) -> void:
	score += amount
	score_label.text = "SCORE: %s" % str(score)


func add_fear(amount: int) -> void:
	if amount > 0:
		fear_increased.emit()
	else:
		fear_decreased.emit()


	fear += amount

	if fear < 0:
		fear = 0

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

	for dice_i: int in range(dice_to_roll):
		dice.append({"kind": "base", "name": type})

	type_label.text = "TYPE: %s" % selected_base
	toppings_selector.show()
	update_dice_count()


func _on_toppings_selected(_filling: String, _topping: String, _decoration: String) -> void:
	toppings_selector.hide()

	if _filling != "":
		filling = _filling
		dice.append({"kind": "filling", "name": filling})

	if _topping != "":
		topping = _topping
		dice.append({"kind": "topping", "name": topping})

	if _decoration != "":
		decoration = _decoration
		dice.append({"kind": "decoration", "name": decoration})

	print("NOW ROLL YOUR LUCK | DICE %s" % dice_to_roll)
	roll_dice()


func roll_dice() -> void:
	bust = false
	dice_well.roll_dice(dice)
	dice = []
	dice_to_roll = 0
	update_dice_count()


func _on_topping_pressed(is_toggled: bool) -> void:
	if is_toggled:
		dice_to_roll += 1
	else:
		dice_to_roll -= 1

	update_dice_count()


func _on_roll_finished() -> void:
	view_oven.emit()
