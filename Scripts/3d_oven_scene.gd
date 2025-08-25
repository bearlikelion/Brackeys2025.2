extends Node3D

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if game_manager != null :
		game_manager.view_oven.connect(_on_view_oven)


func _on_view_oven() -> void:
	print("View Oven")
	animation_player.play('view_oven')


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "view_oven":
		print("Open Oven")
		animation_player.play("open_oven")

	if anim_name == "open_oven":
		print("View Table")
		animation_player.play("view_table")
