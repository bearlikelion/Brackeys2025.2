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

	# HACK UNTIL IN IMPLEMENT ALL ROUNDS
	if game_manager.instructions_round > 1:
		return true

	if _type not in rq_type:
		return false
	if _filling != "" and _filling not in rq_filling:
		return false
	if _topping != "" and _topping not in rq_topping:
		return false
	if _decoration != "" and _decoration not in rq_decoration:
		return false

	# round one
	if game_manager.instructions_round == 1:
		if _topping != "" or _decoration != "":
			return false

	return true


func set_instructions(_round: int, _instruction_index: int) -> void:
	game_manager.instructions_round = _round
	game_manager.instruction_index = _instruction_index
	match _round:
		1:
			round_one_rules(_instruction_index)


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
