class_name OvenScene
extends Node3D

const SHORTBREAD = preload("res://Scenes/Biscuits/shortbread.tscn")

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var biscuit_spawn: Marker3D = $BiscuitSpawn
@onready var biscuit: Node3D = $Biscuit


func _ready() -> void:
	add_to_group("OvenScene")


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "table_to_oven":
		print("Open Oven")
		animation_player.play("open_oven")

	if anim_name == "open_oven":
		print("View Table")
		animation_player.play("oven_to_table")
		game_manager.new_round()


func add_biscuit(base_name: String) -> void:
	var new_biscuit = RigidBody3D

	match base_name:
		"Shortbread":
			new_biscuit = SHORTBREAD.instantiate()

	biscuit.add_child(new_biscuit)
	new_biscuit.global_position = biscuit_spawn.position
