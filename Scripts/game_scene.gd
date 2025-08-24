extends Node3D

var total: int = 0
var score: int = 0
var dice_rolled: int = 0
var biscuits_baked: int = 0

var cracked_biscuit: bool = false
var enchanted_biscuit: bool = true

var type: String
var filling: String
var filling_score: int = 0
var topping: String

@onready var dice_well: DiceWell = $DiceWell
@onready var type_label: Label = %TypeLabel
@onready var topping_label: Label = %ToppingLabel
@onready var filling_label: Label = %FillingLabel
@onready var score_label: Label = %ScoreLabel
@onready var total_label: Label = %TotalLabel
@onready var mutators_bar: VBoxContainer = %MutatorsBar
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
		_:
			set_mutator(dice_face)


func add_score(amount: int) -> void:
	score += amount
	score_label.text = "SCORE: %s" % str(score)


func set_type(dice_face: int) -> void:
	match dice_face:
		1:
			type_label.text = "TYPE: Digestive (1)"
			add_score(1)
		2:
			type_label.text = "TYPE: Shortbread (2)"
			add_score(2)
		3:
			type_label.text = "TYPE: Oat (2)"
			add_score(2) # TODO Immune to first bust
		4:
			type_label.text = "TYPE: Chocolate Chip (3)"
			add_score(3)
		5:
			type_label.text = "TYPE: Biscotti (6)"
			add_score(6) # TODO Increased bust chance
		6:
			type_label.text = "TYPE: Golden Biscuit (10)"
			add_score(10)


func set_filling(dice_face: int) -> void:
	match dice_face:
		1:
			filling_label.text = "FILLING: Vanilla Cream (1)"
			filling_score = 1
			add_score(1)
		2:
			filling_label.text = "FILLING: Chocolate Cream (4)"
			filling_score = 4
			add_score(4)
		3:
			filling_label.text = "FILLING: Jam (3)"
			filling_score = 3
			add_score(3) # TODO Half score if bust
		4:
			filling_label.text = "FILLING: Peanut Butter (6)"
			filling_score = 6
			add_score(6) # TODO Bust chance doubles
		5:
			filling_label.text = "FILLING: Marshmallow (3)"
			filling_score = 3
			add_score(3) # TODO Double Topping Score
		6:
			filling_label.text = "FILLING: Mystery Filling (5)"
			filling_score = 5
			add_score(5) # TODO Roll again (1-3) = +5 Points | (4-6) = bust


func set_topping(dice_face: int) -> void:
	match dice_face:
		1:
			topping_label.text = "TOPPING: Powdered Sugar (1)"
			add_score(1)
		2:
			topping_label.text = "TOPPING: Chocolate Drizzle (3)"
			add_score(3)
		3:
			topping_label.text = "TOPPING: Sprinkles (2)"
			add_score(2) # TODO x2 to next roll
		4:
			topping_label.text = "TOPPING: Caramel Glaze (4)"
			add_score(4) # TODO Next roll is 2 dice
		5:
			topping_label.text = "TOPPING: Nuts (5)"
			add_score(5) # TODO +1 bust to next roll
		6:
			topping_label.text = "TOPPING: WILD (6)"
			add_score(6) # TODO choose any topping


func set_mutator(dice_face: int) -> void:
	var mutator_label: Label = Label.new()
	var mutator_string: String = ""

	match dice_face:
		1:
			mutator_string = "Burnt Edge (-3)"
			add_score(-3)
		2:
			mutator_string = "Double Stuff (2x Filling)"
			add_score(filling_score)
		3:
			mutator_string = "Cracked Biscuit"
			if cracked_biscuit:
				biscuiit_bust()
			else:
				cracked_biscuit = true
		4:
			mutator_string = "Enchanted Biscuit"
			if not enchanted_biscuit:
				enchanted_biscuit = true
		5:
			mutator_string = "Exploding Biscuit"
			biscuiit_bust()
		6:
			mutator_string = "🌈Rainbow Biscuit"
			add_score(20)


func _on_roll_button_pressed() -> void:
	dice_well.roll_die()


func clear_mutators() -> void:
	for child: Label in mutators_bar.get_children():
		child.queue_free()


func _on_bake_button_pressed() -> void:
	dice_well.clear_dice()
	biscuits_baked += 1
	bake_button.hide()
	clear_mutators()
	dice_rolled = 0
	total += score
	score = 0

	if biscuits_baked < 6:
		total_label.text = "TOTAL: %s" % total
		type_label.text = "TYPE: NONE"
		filling_label.text = "FILLING: NONE"
		topping_label.text = "TOPPING: NONE"
		score_label.text = "SCORE: 0"
	else:
		print("GAME OVER: %s" % total)


func biscuiit_bust() -> void:
	dice_well.clear_dice()
	biscuits_baked += 1
	bake_button.hide()
	clear_mutators()
	dice_rolled = 0
	print("BISCUIT BUST")
