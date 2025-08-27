class_name FloatingNumber
extends Control

@export var animation_duration: float = 5.0


var target_position: Vector2
var start_position: Vector2
var is_fear: bool = false
var amount: int = 0
var animation_time: float = 0.0


@onready var label: Label = $Label


func _ready() -> void:
	modulate.a = 0.0


func _process(delta: float) -> void:
	if animation_time < animation_duration:
		animation_time += delta
		var t: float = animation_time / animation_duration

		# Ease out cubic for smooth deceleration
		t = 1.0 - pow(1.0 - t, 3.0)

		# Interpolate position
		global_position = start_position.lerp(target_position, t)

		# Add slight arc to movement
		var arc_height: float = 50.0
		var arc_offset: float = sin(t * PI) * arc_height
		global_position.y -= arc_offset

		# Fade in and out
		if t < 0.2:
			modulate.a = t * 5.0
		elif t > 0.8:
			modulate.a = (1.0 - t) * 5.0
		else:
			modulate.a = 1.0

		# Scale animation
		if t < 0.2:
			scale = Vector2.ONE * (0.5 + t * 2.5)
		else:
			scale = Vector2.ONE * (1.0 + (1.0 - t) * 0.2)
	else:
		queue_free()


func setup(from_pos: Vector2, to_pos: Vector2, value: int, is_fear_value: bool = false) -> void:
	start_position = from_pos
	target_position = to_pos
	global_position = from_pos
	amount = value
	is_fear = is_fear_value

	# Update the label text and color based on the amount
	if amount > 0:
		label.text = "+%d" % amount
		label.modulate = Color.GREEN if not is_fear else Color.PURPLE
	elif amount < 0:
		label.text = "%d" % amount
		label.modulate = Color.RED if not is_fear else Color.YELLOW
	else:
		return  # Don't show anything for 0
