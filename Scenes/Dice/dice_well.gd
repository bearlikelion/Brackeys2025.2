class_name DiceWell
extends Node

const d_6 = preload("res://Scenes/Dice/d6.tscn")

signal dice_rolled()
signal roll_result()

@onready var roll_die_button: Button = $DebugUI/RollDie
@onready var dice: Node = $Dice


func _ready() -> void:
	roll_die_button.pressed.connect(roll_die)


func roll_die() -> void:
	var d6: D6 = d_6.instantiate()
	d6.position = Vector3(0, 0.3, 0)
	d6.roll_result.connect(_on_roll_result)
	dice.add_child(d6)
	dice_rolled.emit()


func _on_roll_result(dice_face: int) -> void:
	roll_result.emit(dice_face)


func clear_dice() -> void:
	for child: D6 in dice.get_children():
		child.queue_free()
