class_name DiceWell
extends Node

const d_6 = preload("res://Scenes/Dice/d6.tscn")

signal dice_rolled()
signal roll_finished()
signal roll_result(dice_face: int, dice_type: String, dice_name: String)

@onready var dice: Node = $Dice


func _ready() -> void:
	pass

func roll_die(die: Dictionary) -> void:
	var d6: D6 = d_6.instantiate()
	d6.position = Vector3(0, 0.3, 0)
	d6.roll_result.connect(_on_roll_result)

	if die.has("kind"):
		d6.kind = die.kind

	if die.has("name"):
		d6.die_name = die.name

	dice.add_child(d6)
	dice_rolled.emit()


func roll_dice(dice: Array) -> void:
	for dice_i: int in range(dice.size()):
		roll_die(dice[dice_i])
		await get_tree().create_timer(0.1).timeout

	await get_tree().create_timer(1.5).timeout
	roll_finished.emit()


func _on_roll_result(dice_face: int, dice_type: String, dice_name: String) -> void:
	roll_result.emit(dice_face, dice_type, dice_name)


func clear_dice() -> void:
	for child: D6 in dice.get_children():
		child.queue_free()
