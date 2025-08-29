class_name ScoreScreen
extends MarginContainer

@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

@onready var victory_label: Label = $Panel/VBoxContainer/VictoryLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var time_label: Label = $Panel/VBoxContainer/TimeLabel
@onready var bisctuits_label: Label = $Panel/VBoxContainer/BisctuitsLabel


func _ready() -> void:
	if visible:
		hide()

	game_manager.victory.connect(_on_victory)
	game_manager.game_over.connect(_on_game_over)


func calculate_score() -> void:
	score_label.text = "Score: %d" % game_manager.score

	var end_time: int = Time.get_ticks_msec()
	var play_time_seconds: int = (end_time - game_manager.start_time) / 1000
	var minutes: int = play_time_seconds / 60
	var seconds: int = play_time_seconds % 60

	time_label.text = "Time: %d:%02d" % [minutes, seconds]

	bisctuits_label.text = "Biscuits Baked: %d" % game_manager.biscuits_baked


func _on_victory() -> void:
	victory_label.text = "VICTORY"
	calculate_score()
	show()


func _on_game_over() -> void:
	victory_label.text = "DEFEAT"
	calculate_score()
	show()


func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
