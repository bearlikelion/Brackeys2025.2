class_name ChatInstructions
extends RichTextLabel

signal instructions_done()
signal message_complete()

@export var timer_to_speak: float = 2.0

var dialogue_by_round: Dictionary = {
	1: [
		"Let's start simple, a plain shortbread with some sweet filling.",
		"Bake me a heart biscuit… nothing fancy, just a little glaze.",
		"A square will do, but dress it with cream so I know you care."
	],
	2: [
		"Now, something bolder… perhaps a round biscuit with jam filling.",
		"A gingerbread person, but give them eyes, so they can see me.",
		"Skull biscuits… drizzle them in sugar so they shine."
	],
	3: [
		"Mmm, I’m hungry for more layers. Add a topping, add a filling, don’t be shy.",
		"Try something round again, but sweeter this time… and don’t let it crack.",
		"Bake me a coffin-shaped one — no, wait… square, round, I don’t care, just add cream."
	],
	4: [
		"More. Bigger. Pile it higher. I want to taste the risk in every bite.",
		"Why stop at one layer? Give me a filling, topping, and decoration, stack it all!",
		"Give them eyes! I want them to stare back at me!"
	],
	5: [
		"Don’t think just bake. Any shape, any flavor, so long as it bleeds sweetness.",
		"Round, square, skull, does it matter? Just make it worthy of me.",
		"Yes… yes… decorate them, ruin them, let the oven decide."
	],
	6: [
		"All biscuits crumble in the end… feed me anything.",
		"The shapes blur… shortbread, skull, gingerbread, they all taste the same now.",
		"No recipe left, only hunger. Bake, or be baked."
	]
}

var typewriter_speed: float = 0.0
var chars_per_second: float = 0.0
var time_accumulator: float = 0.0
var instructions_finished: bool = false

@onready var talk_sound: AudioStreamPlayer = $TalkSound
@onready var chat_message: MarginContainer = %ChatMessage
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")


func _ready() -> void:
	visible_ratio = 0.0
	game_manager.biscuit_broken.connect(_on_biscuit_broken)
	game_manager.biscuit_invalid.connect(_on_biscuit_invalid)


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

		if game_manager.biscuit_broke or not game_manager.valid_biscuit:
			await get_tree().create_timer(2.0).timeout

		instructions_done.emit()


func new_instructions() -> void:
	text = ""

	var _round: int = game_manager.round
	if _round >= 7:
		_round = randi_range(1, 6)
	if _round == 0: # HACK I AM TOO TIRED TO CARE
		_round = 1

	var instructions_count: int = dialogue_by_round[_round].size()
	var instructions_index: int = randi_range(0, instructions_count -1)
	var instructions: String = dialogue_by_round[_round][instructions_index]

	game_manager.set_instructions(_round, instructions_index)
	say_message(instructions)


func say_message(message: String) -> void:
	instructions_finished = false
	chat_message.show()
	show()

	text = message
	text.capitalize()

	var total_chars: int = get_total_character_count()
	if total_chars > 0:
		chars_per_second = total_chars / timer_to_speak
		typewriter_speed = 1.0 / total_chars * chars_per_second

	visible_ratio = 0.0
	time_accumulator = 0.0


func _on_biscuit_broken() -> void:
	await game_manager.game_camera.animation_player.animation_finished

	var broken_messages: Array[String] = [
		"How dare you break my biscuit!",
		"I thought I told you no cracks!",
		"Breaking before baking?!?!?",
		"The oven hungers, i'll feed it you if you continue to fail me"
	]

	say_message(broken_messages.pick_random())


func _on_biscuit_invalid() -> void:
	await game_manager.game_camera.animation_player.animation_finished

	var invalid_message: Array[String] = [
		"That's not what I told you to make",
		"Can you not follow my instructions?!",
		"What did you think I asked for",
		"Follow my directions or die",
		"You did not listen to meeeeeeee"
	]

	say_message(invalid_message.pick_random())
