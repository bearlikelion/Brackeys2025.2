extends Camera3D

enum Viewing { TABLE, OVEN, WITCH, ITEMS }

var looking_at = Viewing.TABLE

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	add_to_group("GameCamera")


func view_oven() -> void:
	pass


func view_table() -> void:
	match looking_at:
		Viewing.OVEN:
			animation_player.play("view_table")


func view_witch() -> void:
	pass


func view_items() -> void:
	pass
