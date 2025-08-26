class_name DiceWell
extends Node3D

const d_6 = preload("res://Scenes/Dice/d6.tscn")

signal dice_rolled()
signal roll_finished()
signal roll_result(dice_face: int, dice_type: String, dice_name: String, dice_position: Vector3)

var last_dices :Array [D6]
var dice_to_roll: int = 0
var rolled_dice: int = 1
var rolled_results: Array

@onready var dice: Node = $Dice
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var camera_3d: GameCamera = get_tree().get_first_node_in_group("GameCamera")
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	game_manager.biscuit_broken.connect(_on_biscuit_broken)


func roll_die(die: Dictionary) -> void:
	var d6: D6 = d_6.instantiate()
	d6.position = Vector3.ZERO#(randf_range(0.01,0.05), randf_range(0.01,0.05), randf_range(0.01,0.05))
	last_dices.append(d6)
	d6.roll_result.connect(_on_roll_result)

	if die.has("kind"):
		d6.kind = die.kind

	if die.has("name"):
		d6.die_name = die.name

	dice.add_child(d6)
	dice_rolled.emit()


func roll_dice(dice_array: Array) -> void:
	animation_player.play("dice_roll")
	last_dices.clear()
	rolled_results.clear()
	dice_array.shuffle()

	dice_to_roll = dice_array.size()
	rolled_dice = 0

	for dice_i: int in range(dice_array.size()):
		roll_die(dice_array[dice_i])
		await get_tree().create_timer(randf_range(0.05, 0.1)).timeout

	# await get_tree().create_timer(2.5).connect("timeout", dice_to_face)


func dice_to_face() -> void:
	#var start_pos = get_viewport().size/2
	if game_manager.biscuit_broke:
		return

	animate_dice_to_grid()
	score_dice()


func animate_dice_to_grid() -> void:
	if not camera_3d:
		print("Error: camera_3d is not set")
		return

	var dice_count := last_dices.size()
	if dice_count == 0:
		return
	var grid_size: int = ceil(sqrt(dice_count))
	var spacing: float = 0.07
	var half_grid: float = (grid_size - 1) / 2.0

	var index: int = 0
	var delay: float = 0.1
	for _d6: D6 in last_dices as Array[D6]:
		if not _d6:
			continue
		_d6.freeze = true
		var row: int = int(index / grid_size) # need fixing
		var col: int = index % grid_size # need fixing
		var local_offset_x: float = (col - half_grid) * spacing
		var local_offset_y: float = -(row - half_grid) * spacing
		var local_pos: Vector3 = Vector3(local_offset_x, local_offset_y, -0.3)  # lets fucking hope it works

		var target_pos: Vector3 = camera_3d.global_transform * local_pos

		get_tree().create_timer(3.5).connect("timeout", _d6.set_deferred.bind("dissolve",true))
		var tween := _d6.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(_d6, "global_position", target_pos, 0.5).set_delay(delay)
		var tween2 := _d6.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tween2.tween_property(_d6, "scale", dice.scale/5, 0.5).set_delay(delay)
		delay += 0.1 + (delay * 0.3)
		index += 1


func _on_roll_result(dice_face: int, dice_type: String, dice_name: String) -> void:
	rolled_dice += 1
	if rolled_dice == dice_to_roll:
		dice_to_face()

	# Find the die that emitted this result to get its position
	#var dice_position: Vector3 = Vector3.ZERO
	#for die in last_dices:
		#if die and die.die_name == dice_name:
			#dice_position = die.global_position
			#break

	rolled_results.append([dice_face, dice_type, dice_name])
	# roll_result.emit(dice_face, dice_type, dice_name, dice_position)


func clear_dice() -> void:
	for child: D6 in dice.get_children():
		child.queue_free()


func _on_biscuit_broken() -> void:
	pass


func score_dice() -> void:
	# Wait for dice to finish animating to grid
	await get_tree().create_timer(1.5).timeout

	# First check if any dice will cause the biscuit to break
	var will_break: bool = check_for_breaking_dice()

	# If biscuit will break, trigger it immediately before scoring
	if will_break:
		game_manager.biscuit_broke = true
		game_manager.biscuit_broken.emit()
		# Add fear based on dice count but don't score anything
		game_manager.add_fear(game_manager.dice_to_roll)
		print("BISCUIT BROKEN! No scoring this round.")

	# Score each die with a small delay between each (scores will be 0 if broken)
	for i in range(rolled_results.size()):
		var result: Array = rolled_results[i]
		var dice_face: int = result[0]
		var dice_type: String = result[1]
		var dice_name: String = result[2]

		# Find the die's current position in the grid
		var dice_position: Vector3 = Vector3.ZERO
		if i < last_dices.size() and last_dices[i]:
			dice_position = last_dices[i].global_position

		# Emit the result to trigger scoring
		roll_result.emit(dice_face, dice_type, dice_name, dice_position)

		# Small delay between scoring each die for visual effect
		await get_tree().create_timer(randf_range(0.15, 0.33)).timeout

	# Clear the results array for next roll
	rolled_results.clear()

	# Wait a bit then emit roll finished
	await get_tree().create_timer(2.0).timeout
	roll_finished.emit()


func check_for_breaking_dice() -> bool:
	# Check if any dice will cause the biscuit to break
	for result in rolled_results:
		var dice_face: int = result[0]
		var dice_type: String = result[1]
		var dice_name: String = result[2]

		# Check Gingerbread base (breaks on 1 or 2)
		if dice_type == "base" and dice_name == "Gingerbread":
			if dice_face <= 2:
				return true

		# Check Custard filling (breaks on 1 or 2)
		if dice_type == "filling" and dice_name == "Custard":
			if dice_face <= 2:
				return true

	return false
