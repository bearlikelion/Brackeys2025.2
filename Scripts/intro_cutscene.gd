extends Control

signal text_finished
signal cutscene_complete

@export var chars_per_second: float = 30.0
@export var click_to_continue_delay: float = 0.5
@export var preload_game_scene: bool = true

@onready var text_label: RichTextLabel = $DialogueBox/MarginContainer/TextLabel
@onready var continue_prompt: Label = $DialogueBox/ContinuePrompt
@onready var dialogue_box: Panel = $DialogueBox
@onready var typing_sound: AudioStreamPlayer = $TypingSound

var dialogue_lines: Array[String] = [
	"Wake up, little baker. The oven hungers.",
	"You will feed it biscuits shaped, filled and topped with my demands.",
	"Decorate as you please, unless there is a decoration I need.",
	"Each biscuit is fragile. Roll the dice, and maybe it holds… maybe it breaks.",
	"Roll low and fail, roll high to succeed",
	"Get it wrong, and the oven will feast on YOU instead.",
	"Now… begin."
]

var current_line: int = 0
var current_char: int = 0
var time_accumulator: float = 0.0
var is_typing: bool = false
var can_continue: bool = false
var preloaded_scene: PackedScene = null


func _ready() -> void:
	continue_prompt.visible = false
	text_label.text = ""

	if preload_game_scene:
		_start_preloading()

	await get_tree().create_timer(0.5).timeout
	_display_next_line()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_continue()
	elif event.is_action_pressed("ui_accept"):
		_handle_continue()


func _start_preloading() -> void:
	preloaded_scene = load("res://Scenes/game_scene.tscn")


func _process(delta: float) -> void:
	if is_typing:
		_process_typing(delta)


func _process_typing(delta: float) -> void:
	time_accumulator += delta

	var chars_to_show: int = int(time_accumulator * chars_per_second)
	if chars_to_show > 0:
		time_accumulator = 0.0

		for i in range(chars_to_show):
			if current_char >= dialogue_lines[current_line].length():
				_finish_typing()
				break

			var current_text: String = dialogue_lines[current_line]
			var char_to_add: String = current_text[current_char]

			text_label.text += char_to_add

			if typing_sound and randf() > 0.7:
				typing_sound.pitch_scale += randf_range(-0.1, 0.1)
				typing_sound.play()

			current_char += 1


func _finish_typing() -> void:
	is_typing = false
	text_finished.emit()

	await get_tree().create_timer(click_to_continue_delay).timeout
	can_continue = true

	if current_line < dialogue_lines.size() - 1:
		continue_prompt.visible = true
		var tween: Tween = create_tween()
		tween.set_loops()
		tween.tween_property(continue_prompt, "modulate:a", 0.3, 0.5)
		tween.tween_property(continue_prompt, "modulate:a", 1.0, 0.5)
	else:
		await get_tree().create_timer(1.0).timeout
		_transition_to_game()


func _handle_continue() -> void:
	if not can_continue:
		if is_typing:
			_skip_typing()
		return

	can_continue = false
	continue_prompt.visible = false

	current_line += 1
	if current_line < dialogue_lines.size():
		_display_next_line()
	else:
		_transition_to_game()


func _skip_typing() -> void:
	is_typing = false
	var remaining_text: String = dialogue_lines[current_line].substr(current_char)
	text_label.text += remaining_text
	current_char = dialogue_lines[current_line].length()
	_finish_typing()


func _display_next_line() -> void:
	if current_line > 0:
		text_label.text += "\n\n"  # Add spacing between dialogue lines
	current_char = 0
	is_typing = true
	can_continue = false


func _transition_to_game() -> void:
	cutscene_complete.emit()

	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await fade_tween.finished

	if preloaded_scene:
		get_tree().change_scene_to_packed(preloaded_scene)
	else:
		get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")
