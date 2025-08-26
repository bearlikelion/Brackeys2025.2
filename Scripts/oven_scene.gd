extends Node3D

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	pass


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "table_to_oven":
		print("Open Oven")
		animation_player.play("open_oven")

	if anim_name == "open_oven":
		print("View Table")
		animation_player.play("oven_to_table")
		game_manager.new_round()
