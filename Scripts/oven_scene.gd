class_name OvenScene
extends Node3D

const SHORTBREAD = preload("res://Scenes/Biscuits/shortbread.tscn")
const HEART = preload("res://Scenes/Biscuits/heart.tscn")
const ROUND = preload("res://Scenes/Biscuits/round.tscn")
const SQUARE = preload("res://Scenes/Biscuits/square.tscn")
const GINGERBREAD = preload("res://Scenes/Biscuits/gingerbread.tscn")
const SKULL = preload("res://Scenes/Biscuits/skull.tscn")

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
	var new_biscuit: Biscuit

	match base_name:
		"Shortbread":
			new_biscuit = SHORTBREAD.instantiate()
		"Heart":
			new_biscuit = HEART.instantiate()
		"Round":
			new_biscuit = ROUND.instantiate()
		"Square":
			new_biscuit = SQUARE.instantiate()
		"Gingerbread":
			new_biscuit = GINGERBREAD.instantiate()
		"Skull":
			new_biscuit = SKULL.instantiate()

	biscuit.add_child(new_biscuit)
	new_biscuit.rotation_degrees.x = randf_range(-15.0, 15.0)
	new_biscuit.rotation_degrees.z = randf_range(-15.0, 15.0)
	new_biscuit.global_position = biscuit_spawn.position
