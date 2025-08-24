class_name DiceWell
extends Node

const d_6 = preload("res://Scenes/Dice/d6.tscn")

@onready var roll_die: Button = $DebugUI/RollDie
@onready var dice: Node = $Dice


func _ready() -> void:
	roll_die.pressed.connect(_on_roll_die)


func _on_roll_die() -> void:
	var d6: D6 = d_6.instantiate()
	dice.add_child(d6)
