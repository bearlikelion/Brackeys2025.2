extends Node

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	pass


func score_die(dice_type: String, dice_name: String, dice_face: int) -> void:
	if dice_type == "base":
		score_base_die(dice_name, dice_face)


func score_base_die(dice_name: String, dice_face: int) -> void:
	match dice_name:
		"Shortbread":
			score_shortbread(dice_face)
		"Heart":
			score_heart(dice_face)
		"Square":
			score_square(dice_face)
		"Round":
			score_round(dice_face)
		"Gingerbread":
			score_gingerbread(dice_face)
		"Skull":
			score_skull(dice_face)


# Ignore Fear | Low Score
func score_shortbread(dice_face: int) -> void:
	match dice_face:
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(4)


# On Success: -Fear | On Fail: Double Fear
func score_heart(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(2)
		2:
			game_manager.add_fear(4)
		3:
			game_manager.add_score(1)
			game_manager.add_fear(-1)
		4:
			game_manager.add_score(2)
			game_manager.add_fear(-2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(4)


# 6s are 2x Score
func score_square(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(1)
		2:
			game_manager.add_fear(2)
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(8)


# On Failure, reroll one die TODO
func score_round(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(1)
		2:
			game_manager.add_fear(2)
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(8)


# On fail, ginger snaps
func score_gingerbread(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.bust_biscit()
			game_manager.add_fear(1)
		2:
			game_manager.bust_biscuit()
			game_manager.add_fear(2)
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(8)


func score_skull(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(2)
		2:
			game_manager.add_fear(4)
		3:
			game_manager.add_score(2)
		4:
			game_manager.add_score(4)
		5:
			game_manager.add_score(6)
		6:
			game_manager.add_score(16)
