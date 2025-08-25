class_name ChatInstructions
extends RichTextLabel

signal instructions_done()

@export var timer_to_speak: float = 1.5

var typewriter_speed: float = 0.0
var chars_per_second: float = 0.0
var time_accumulator: float = 0.0
var instructions_finished: bool = false

@onready var talk_sound: AudioStreamPlayer = $TalkSound

func _ready() -> void:
	visible_ratio = 0.0
	var total_chars: int = get_total_character_count()
	if total_chars > 0:
		chars_per_second = total_chars / timer_to_speak
		typewriter_speed = 1.0 / total_chars * chars_per_second


func _physics_process(delta: float) -> void:
	if visible_ratio < 1.0:
		# Increment visible ratio based on typewriter speed
		time_accumulator += delta
		visible_ratio = min(1.0, time_accumulator * typewriter_speed)

		# Check if we've revealed a new word (passed a space)
		if not talk_sound.playing:
			talk_sound.pitch_scale = 1.0 + randf_range(-0.3, 0.3)
			talk_sound.play()
	elif not instructions_finished:
		instructions_finished = true
		instructions_done.emit()
