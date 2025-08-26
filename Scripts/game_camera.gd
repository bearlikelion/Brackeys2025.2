class_name GameCamera
extends Camera3D

enum Viewing { TABLE, OVEN, WITCH, ITEMS }

var looking_at: Viewing = Viewing.TABLE

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	add_to_group("GameCamera")
	game_manager.biscuit_broken.connect(_on_biscuit_broken)
	animation_player.animation_finished.connect(_on_animation_finished)


func view_oven() -> void:
	match looking_at:
		Viewing.TABLE:
			animation_player.play("table_to_oven")


func view_table() -> void:
	match looking_at:
		Viewing.OVEN:
			animation_player.play("oven_to_table")
		Viewing.WITCH:
			animation_player.play("witch_to_table")


func view_witch() -> void:
	match looking_at:
		Viewing.TABLE:
			animation_player.play("table_to_witch")


func view_items() -> void:
	pass


func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		"oven_to_table":
			looking_at = Viewing.TABLE
		"table_to_oven":
			looking_at = Viewing.OVEN
		"table_to_witch":
			looking_at = Viewing.WITCH
		"witch_to_table":
			looking_at = Viewing.TABLE


func _on_biscuit_broken() -> void:
	view_witch()
