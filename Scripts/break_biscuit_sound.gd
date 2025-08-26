extends AudioStreamPlayer

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	game_manager.biscuit_broken.connect(_on_biscuit_broken)


func _on_biscuit_broken() -> void:
	pitch_scale = 1.0 + randf_range(-0.33, 0.33)
	play()
