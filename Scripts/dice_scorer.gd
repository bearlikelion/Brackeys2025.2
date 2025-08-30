class_name DiceScorer
extends Node

const FLOATING_NUMBER = preload("res://Scenes/UI/floating_number.tscn")

var reroll_fail: bool = false
var success_die: int = 0
var last_die_position: Vector3 = Vector3.ZERO

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var dice_well: DiceWell = get_tree().get_first_node_in_group("DiceWell")
@onready var fct: Control = %FCT


func _ready() -> void:
	add_to_group("DiceScorer")
	game_manager.round_started.connect(_on_round_started)


func spawn_floating_number(amount: int, is_fear: bool = false) -> void:
	if amount == 0:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return

	var screen_pos: Vector2

	# Check if we have a valid die position
	if last_die_position == Vector3.ZERO:
		# No die position - wait for camera animation if needed
		if game_manager.game_camera.animation_player.is_playing():
			await game_manager.game_camera.animation_player.animation_finished

		# Use center of screen as starting position
		var viewport: Viewport = get_viewport()
		screen_pos = viewport.get_visible_rect().size / 2.0
	else:
		# Get die position in screen space
		screen_pos = camera.unproject_position(last_die_position)

	# Get target position (score or fear label)
	var target_control: Control
	if is_fear:
		target_control = game_manager.fear_progress
	else:
		target_control = game_manager.score_progress

	if not target_control:
		return

	var target_pos: Vector2 = target_control.global_position + target_control.size / 2.0

	# Create floating number
	var floating_num: FloatingNumber = FLOATING_NUMBER.instantiate()
	fct.add_child(floating_num)
	floating_num.setup(screen_pos, target_pos, amount, is_fear)


func _on_round_started() -> void:
	last_die_position = Vector3.ZERO


func score_die(dice_type: String, dice_name: String, dice_face: int) -> void:
	if dice_face >= 5:
		success_die += 1

	if dice_type == "base":
		score_base_die(dice_name, dice_face)

	if dice_type == "filling":
		score_filling_die(dice_name, dice_face)

	if dice_type == "topping":
		score_topping_die(dice_name, dice_face)

	if dice_type == "decoration":
		score_decoration_die(dice_name, dice_face)


func score_base_die(dice_name: String, dice_face: int) -> void:
	match dice_name:
		"Shortbread":
			score_shortbread(dice_face)
		"Heart":
			score_heart(dice_face)
		"Round":
			score_round(dice_face)
		"Square":
			score_square(dice_face)
		"Gingerbread":
			score_gingerbread(dice_face)
		"Skull":
			score_skull(dice_face)


func score_filling_die(dice_name: String, dice_face: int) -> void:
	match dice_name:
		"Jam":
			score_jam_filling(dice_face)
		"Cream":
			score_cream_filling(dice_face)
		"Custard":
			score_custard_filling(dice_face)
		"Marrow":
			score_marrow_filling(dice_face)


func score_topping_die(dice_name: String, dice_face: int) -> void:
	match dice_name:
		"Sugar":
			score_sugar_topping(dice_face)
		"Icing":
			score_icing_topping(dice_face)
		"Frosting":
			score_frosting_topping(dice_face)
		"Caramel":
			score_caramel_topping(dice_face)


func score_decoration_die(dice_name: String, dice_face: int) -> void:
	match dice_name:
		"Tongue":
			score_tongue_decoration(dice_face)
		"Eyes":
			score_eyes_decoration(dice_face)


## BASE BISCUITS
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
			# game_manager.add_score(1)
			game_manager.add_fear(-1)
		4:
			#game_manager.add_score(2)
			game_manager.add_fear(-2)
		5:
			# game_manager.add_score(3)
			game_manager.add_fear(-3)
		6:
			# game_manager.add_score(4)
			game_manager.add_fear(-4)


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
			game_manager.add_score(8)
		5:
			game_manager.add_score(4)
		6:
			game_manager.add_score(6)


# On Failure, TODO reroll one failed die
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
			game_manager.add_fear(1)
			game_manager.add_score(-2)
		2:
			game_manager.add_fear(2)
			game_manager.add_score(-4)
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(4)


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
			game_manager.add_score(8)


## FILLINGS
# On failure +2 Fear | Success 2x Score
func score_jam_filling(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(2)
		2:
			game_manager.add_fear(4)
		3:
			game_manager.add_score(2)
			game_manager.add_fear(2)
		4:
			game_manager.add_score(4)
			game_manager.add_fear(2)
		5:
			game_manager.add_score(6)
			game_manager.add_fear(2)
		6:
			game_manager.add_score(8)
			game_manager.add_fear(2)


# Stable, base scoring
func score_cream_filling(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(1)
		2:
			game_manager.add_fear(1)
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(2)
		5:
			game_manager.add_score(3)
		6:
			game_manager.add_score(4)


# Success, double score, one failure it breaks
func score_custard_filling(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(2)
			game_manager.add_score(-2)
		2:
			game_manager.add_fear(4)
			game_manager.add_score(-4)
		3:
			game_manager.add_score(2)
		4:
			game_manager.add_score(4)
		5:
			game_manager.add_score(8)
		6:
			game_manager.add_score(16)


# Success: -Fear | Failure: +2 Fear
func score_marrow_filling(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(2)
		2:
			game_manager.add_fear(2)
		3:
			game_manager.add_fear(-1)
		4:
			game_manager.add_fear(-1)
		5:
			game_manager.add_fear(-2)
		6:
			game_manager.add_fear(-2)


# Small score, no negative
func score_sugar_topping(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(1)
		2:
			game_manager.add_fear(1)
		3:
			game_manager.add_score(1)
		4:
			game_manager.add_score(1)
		5:
			game_manager.add_score(2)
		6:
			game_manager.add_score(2)


# Success: Bouns Points | Failure: Cracks (-Points) + Fear
func score_icing_topping(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_score(-1)
			game_manager.add_fear(1)
		2:
			game_manager.add_score(-2)
			game_manager.add_fear(2)
		3:
			game_manager.add_score(-3)
			game_manager.add_fear(3)
		4:
			game_manager.add_score(4)
		5:
			game_manager.add_score(6)
		6:
			game_manager.add_score(8)


# Low score for high points, high score is fear spike
func score_frosting_topping(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_score(6)
		2:
			game_manager.add_score(4)
		3:
			game_manager.add_score(2)
			game_manager.add_fear(2)
		4:
			game_manager.add_fear(4)
		5:
			game_manager.add_fear(6)
		6:
			game_manager.add_fear(8)


# High Score but always +1 Fear
func score_caramel_topping(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(2)
		2:
			game_manager.add_fear(2)
		3:
			game_manager.add_score(2)
			game_manager.add_fear(1)
		4:
			game_manager.add_score(2)
			game_manager.add_fear(1)
		5:
			game_manager.add_score(4)
			game_manager.add_fear(1)
		6:
			game_manager.add_score(4)
			game_manager.add_fear(1)


# +Points based on successful dice
func score_sprinkles_decoration() -> void:
	game_manager.add_score(success_die)


# -Fear
func score_tongue_decoration(dice_face: int) -> void:
	match dice_face:
		1:
			game_manager.add_fear(-1)
		2:
			game_manager.add_fear(-2)
		3:
			game_manager.add_fear(-3)
		4:
			game_manager.add_fear(-4)
		5:
			game_manager.add_fear(-5)
		6:
			game_manager.add_fear(-6)


# Reroll one failed die TODO
func score_runes_decoration() -> void:
	pass


func score_eyes_decoration(dice_face: int) -> void:
	var is_synergy: bool = false
	if game_manager.type == "Gingerbread" or game_manager.type == "Skull":
		is_synergy = true

	match dice_face:
		1:
			game_manager.add_fear(1)
		2:
			game_manager.add_fear(2)
		3:
			if is_synergy:
				game_manager.add_score(2)
			else:
				game_manager.add_score(1)
		4:
			if is_synergy:
				game_manager.add_score(4)
			else:
				game_manager.add_score(2)
		5:
			if is_synergy:
				game_manager.add_score(6)
			else:
				game_manager.add_score(3)
		6:
			if is_synergy:
				game_manager.add_score(8)
			else:
				game_manager.add_score(4)
