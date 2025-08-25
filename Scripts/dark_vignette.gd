extends ColorRect

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	game_manager.fear_increased.connect(_on_fear_increased)
	game_manager.fear_decreased.connect(_on_fear_decreased)


func _on_fear_increased() -> void:
	var dark_material: ShaderMaterial = material.duplicate()
	var radius: float = dark_material.get_shader_parameter("radius")
	radius += 0.05
	dark_material.set_shader_parameter("radius", radius)
	material = dark_material


func _on_fear_decreased() -> void:
	var dark_material: ShaderMaterial = material.duplicate()
	var radius: float = dark_material.get_shader_parameter("radius")
	radius -= 0.05
	dark_material.set_shader_parameter("radius", radius)
	material = dark_material
