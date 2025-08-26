class_name DiceWell
extends Node3D

const d_6 = preload("res://Scenes/Dice/d6.tscn")

signal dice_rolled()
signal roll_finished()
signal roll_result(dice_face: int, dice_type: String, dice_name: String)

var last_dices :Array [D6]
var dice_to_roll: int = 0
var rolled_dice: int = 1

@onready var dice: Node = $Dice
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var camera_3d: Camera3D = get_tree().get_first_node_in_group("GameCamera")

func _ready() -> void:
	pass

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


func roll_dice(dice: Array) -> void:
	animation_player.play("dice_roll")
	last_dices.clear()
	dice.shuffle()

	dice_to_roll = dice.size()
	rolled_dice = 0

	for dice_i: int in range(dice.size()):
		roll_die(dice[dice_i])
		await get_tree().create_timer(randf_range(0.05, 0.1)).timeout

	# await get_tree().create_timer(2.5).connect("timeout", dice_to_face)


func dice_to_face():
	#var start_pos = get_viewport().size/2
	animate_dice_to_grid()
	await get_tree().create_timer(5.5).timeout
	roll_finished.emit()


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
	var delay = 0.1
	for dice in last_dices as Array[D6]:
		if not dice:
			continue
		dice.freeze = true
		var row: int = index / grid_size # need fixing
		var col: int = index % grid_size # need fixing
		var local_offset_x: float = (col - half_grid) * spacing
		var local_offset_y: float = -(row - half_grid) * spacing
		var local_pos: Vector3 = Vector3(local_offset_x, local_offset_y, -0.3)  # lets fucking hope it works

		var target_pos: Vector3 = camera_3d.global_transform * local_pos

		get_tree().create_timer(3.5).connect("timeout", dice.set_deferred.bind("dissolve",true))
		var tween := dice.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tween.tween_property(dice, "global_position", target_pos, 0.5).set_delay(delay)
		var tween2 := dice.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
		tween2.tween_property(dice, "scale", dice.scale/5, 0.5).set_delay(delay)
		delay += 0.1 + (delay * 0.3)
		index += 1


func _on_roll_result(dice_face: int, dice_type: String, dice_name: String) -> void:
	rolled_dice += 1
	if rolled_dice == dice_to_roll:
		dice_to_face()

	roll_result.emit(dice_face, dice_type, dice_name)


func clear_dice() -> void:
	for child: D6 in dice.get_children():
		child.queue_free()
