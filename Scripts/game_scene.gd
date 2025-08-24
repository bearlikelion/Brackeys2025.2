extends Node3D

var total: int = 0
var score: int = 0
var dice_rolled: int = 0
var type: String
var filling: String
var topping: String

@onready var dice_well: DiceWell = $DiceWell
@onready var type_label: Label = %TypeLabel
@onready var topping_label: Label = %ToppingLabel
@onready var filling_label: Label = %FillingLabel
@onready var score_label: Label = %ScoreLabel
@onready var total_label: Label = %TotalLabel
@onready var bake_button: Button = %BakeButton


func _ready() -> void:
	dice_well.dice_rolled.connect(_on_dice_rolled)
	dice_well.roll_result.connect(_on_roll_result)
	bake_button.hide()


func _on_dice_rolled() -> void:
	dice_rolled += 1
	if dice_rolled >= 3 and not bake_button.visible:
		bake_button.show()


func _on_roll_result(dice_face: int) -> void:
	match dice_rolled:
		1:
			set_type(dice_face)
		2:
			set_filling(dice_face)
		3:
			set_topping(dice_face)


func add_score(amount: int) -> void:
	score += amount
	score_label.text = "SCORE: %s" % str(score)


func set_type(dice_face: int) -> void:
	match dice_face:
		1:
			type_label.text = "TYPE: Digestive"
			add_score(1)
		2:
			type_label.text = "TYPE: Shortbread"
			add_score(2)
		3:
			type_label.text = "TYPE: Oat"
			add_score(2) # TODO Immune to first bust
		4:
			type_label.text = "TYPE: Chocolate Chip"
			add_score(3)
		5:
			type_label.text = "TYPE: Biscotti"
			add_score(6) # TODO Increased bust chance
		6:
			type_label.text = "TYPE: Golden Biscuit"
			add_score(10)


func set_filling(dice_face: int) -> void:
	match dice_face:
		1:
			filling_label.text = "FILLING: Vanilla Cream"
			add_score(1)
		2:
			filling_label.text = "FILLING: Chocolate Cream"
			add_score(4)
		3:
			filling_label.text = "FILLING: Jam"
			add_score(3) # TODO Half score if bust
		4:
			filling_label.text = "FILLING: Peanut Butter"
			add_score(6) # TODO Bust chance doubles
		5:
			filling_label.text = "FILLING: Marshmallow"
			add_score(3) # TODO Double Topping Score
		6:
			filling_label.text = "FILLING: Mystery Filling"
			add_score(5) # TODO Roll again (1-3) = +5 Points | (4-6) = bust


func set_topping(dice_face: int) -> void:
	match dice_face:
		1:
			topping_label.text = "TOPPING: Powdered Sugar"
			add_score(1)
		2:
			topping_label.text = "TOPPING: Chocolate Drizzle"
			add_score(3)
		3:
			topping_label.text = "TOPPING: Sprinkles"
			add_score(2) # TODO x2 to next roll
		4:
			topping_label.text = "TOPPING: Caramel Glaze"
			add_score(4) # TODO Next roll is 2 dice
		5:
			topping_label.text = "TOPPING: Nuts"
			add_score(5) # TODO +1 bust to next roll
		6:
			topping_label.text = "TOPPING: WILD"
			add_score(6) # TODO choose any topping


func _on_roll_button_pressed() -> void:
	dice_well.roll_die()


func _on_bake_button_pressed() -> void:
	dice_well.clear_dice()
	bake_button.hide()
	dice_rolled = 0
	total += score
	score = 0

	total_label.text = "TOTAL: %s" % total
	type_label.text = "TYPE: NONE"
	filling_label.text = "FILLING: NONE"
	topping_label.text = "TOPPING: NONE"
	score_label.text = "SCORE: 0"
