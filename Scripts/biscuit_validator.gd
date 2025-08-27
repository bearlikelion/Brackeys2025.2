class_name BiscuitValidator
extends Node

var rq_type: Array
var rq_filling: Array
var rq_topping: Array
var rq_decoration: Array

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	pass


func reset() -> void:
	print("Reset request")
	rq_type = []
	rq_filling = []
	rq_topping = []
	rq_decoration = []


func is_biscuit_valid(_type: String, _filling: String, _topping: String, _decoration: String) -> bool:
	print("Submitted Biscuit: TYPE %s FILLING %s TOPPING %s DECORATION %s" % [_type, _filling, _topping, _decoration])
	print("RQ Validation: TYPE %s FILLING %s TOPPING %s DECORATION %s" % [rq_type, rq_filling, rq_topping, rq_decoration])

	if _type not in rq_type:
		return false
	if _filling != "" and _filling not in rq_filling:
		return false
	if _topping != "" and _topping not in rq_topping:
		return false
	if rq_decoration.size() > 0 and _decoration not in rq_decoration or rq_decoration.size() > 0 and _decoration == "":
		return false

	# round one
	# TODO BETTER ROUND SPECIFIC DETECTION
	#if game_manager.instructions_round == 1:
		#if _topping != "" or _decoration != "":
			#return false
#
	#if game_manager.instructions_round == 2:
		#if _filling != "" or _decoration != "":
			#return false

	return true


func set_instructions(_round: int, _instruction_index: int) -> void:
	game_manager.instructions_round = _round
	game_manager.instruction_index = _instruction_index
	match _round:
		1:
			round_one_rules(_instruction_index) # Fillings only
		2:
			round_two_rules(_instruction_index) # Toppings only
		3:
			round_three_rules(_instruction_index) # Filling + Topping
		4:
			round_four_rules(_instruction_index) # Filling + Topping + Decoration
		5:
			round_five_rules(_instruction_index) # Riddles
		6:
			round_six_rules(_instruction_index) # Unraveling


# Fillings only
func round_one_rules(index: int) -> void:
	match index:
		0:
			rq_type.append("Shortbread")
			rq_filling.append("Jam")
		1:
			rq_type.append("Heart")
			rq_filling.append("Cream")
		2:
			rq_type.append("Round")
			rq_filling.append("Custard")
		3:
			rq_type.append("Square")
			rq_filling.append("Marrow")
		4:
			rq_type.append("Gingerbread")
			rq_filling.append("Jam")
		5:
			rq_type.append("Skull")
			rq_filling.append("Cream")


# Toppings only
func round_two_rules(index: int) -> void:
	match index:
		0:
			rq_type.append("Shortbread")
			rq_topping.append("Sugar")
		1:
			rq_type.append("Heart")
			rq_topping.append("Icing")
		2:
			rq_type.append("Round")
			rq_topping.append("Frosting")
		3:
			rq_type.append("Square")
			rq_topping.append("Caramel")
		4:
			rq_type.append("Gingerbread")
			rq_topping.append("Sugar")
		5:
			rq_type.append("Skull")
			rq_topping.append("Frosting")


# Filling + Topping
func round_three_rules(index: int) -> void:
	match index:
		0:
			rq_type.append("Round")
			rq_filling.append("Cream")
			rq_topping.append("Sugar")
		1:
			rq_type.append("Heart")
			rq_filling.append("Jam")
			rq_topping.append("Icing")
		2:
			rq_type.append("Square")
			rq_filling.append("Custard")
			rq_topping.append("Caramel")
		3:
			rq_type.append("Shortbread")
			rq_filling.append("Marrow")
			rq_topping.append("Frosting")
		4:
			rq_type.append("Gingerbread")
			rq_filling.append("Custard")
			rq_topping.append("Icing")
		5:
			rq_type.append("Skull")
			rq_filling.append("Jam")
			rq_topping.append("Caramel")


# Filling + Topping + Decoration
func round_four_rules(index: int) -> void:
	match index:
		0:
			rq_type.append("Round")
			rq_filling.append("Jam")
			rq_topping.append("Sugar")
			rq_decoration.append("Sprinkles")
		1:
			rq_type.append("Heart")
			rq_filling.append("Cream")
			rq_topping.append("Icing")
			rq_decoration.append("Runes")
		2:
			rq_type.append("Shortbread")
			rq_filling.append("Custard")
			rq_topping.append("Frosting")
			rq_decoration.append("Eyes")
		3:
			rq_type.append("Square")
			rq_filling.append("Marrow")
			rq_topping.append("Caramel")
			rq_decoration.append("Tongue")
		4:
			rq_type.append("Gingerbread")
			rq_filling.append("Jam")
			rq_topping.append("Sugar")
			rq_decoration.append("Sprinkles")
		5:
			rq_type.append("Skull")
			rq_filling.append("Cream")
			rq_topping.append("Caramel")
			rq_decoration.append("Eyes")


# Riddles
func round_five_rules(index: int) -> void:
	match index:
		0:
			rq_type = ["Round", "Shortbread"]
			rq_filling.append("Jam")
			rq_topping = ["Sugar", "Icing"]
			rq_decoration.append("Eyes")
		1:
			rq_type.append("Heart")
			rq_filling = ["Custard", "Marrow"]
			rq_topping = ["Icing", "Sugar"]
			rq_decoration.append("Runes")
		2:
			rq_type.append("Square")
			rq_filling = ["Custard", "Jam"]
			rq_topping = ["Icing", "Caramel"]
			rq_decoration.append("Tongue")
		3:
			rq_type.append("Shortbread")
			rq_filling.append("Cream")
			rq_topping = ["Sugar", "Icing"]
			rq_decoration.append("Eyes")
		4:
			rq_type.append("Gingerbread")
			rq_filling = ["Jam", "Marrow"]
			rq_topping = ["Caramel", "Frosting"]
			rq_decoration.append("Tongue")
		5:
			rq_type.append("Skull")
			rq_filling = ["Marrow", "Custard"]
			rq_topping.append("Frosting")
			rq_decoration.append("Runes")


# Unraveling
func round_six_rules(index: int) -> void:
	match index:
		0:
			rq_type = ["Shortbread", "Heart", "Square", "Round", "Gingerbread", "Skull"]
			rq_filling = ["Jam", "Marrow"]
			rq_topping = ["Frosting", "Caramel"]
			rq_decoration = ["Etched Runes", "Sprinkles"]
		1:
			rq_type = ["Heart", "Round"]
			rq_filling.append("Custard")
			rq_topping.append("Caramel")
			rq_decoration.append("Eyes")
		2:
			rq_type = ["Round", "Shortbread"]
			rq_filling.append("Marrow")
			rq_topping.append("Frosting")
			rq_decoration.append("Runes")
		3:
			rq_type.append("Square")
			rq_filling = ["Cream", "Jam"]
			rq_topping = ["Sugar", "Icing"]
			rq_decoration.append("Tongue")
		4:
			rq_type.append("Gingerbread")
			rq_filling = ["Cream", "Custard"]
			rq_topping.append("Icing")
			rq_decoration.append("Sprinkles")
		5:
			rq_type.append("Skull")
			rq_filling = ["Marrow", "Custard"]
			rq_topping.append("Caramel")
			rq_decoration.append("Eyes")
