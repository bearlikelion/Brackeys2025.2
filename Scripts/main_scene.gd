extends Node

@export var skip_cutscene: bool = false


func _on_start_button_pressed() -> void:
	if skip_cutscene:
		get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/intro_cutscene.tscn")
