class_name ChatInstructions
extends RichTextLabel

signal instructions_done()

@export var timer_to_speak: float = 2.0

var dialogue_by_round: Dictionary = {
	1: [ # Fillings only
		"Make it simple: a shortbread with jam inside",
		"Bake me a heart, filled with cream, soft and sweet",
		"A round biscuit with custard at its core",
		"Square and steady, but hide marrow within",
		"Gingerbread person, give them a jam heart",
		"Skull biscuits, cracked open and leaking cream"
	],
	2: [ # Toppings only
		"Now, coat a shortbread in sugar glaze",
		"A heart with neat royal icing, to please me",
		"Round biscuit dripping with cursed frosting",
		"Square with burnt caramel, bitter and sharp",
		"Gingerbread person glazed over in sugar",
		"Skull glazed in black frosting, veins spreading"
	],
	3: [ # Filling + Topping
		"Round with cream inside and sugar glaze above",
		"A heart filled with jam, royal icing to finish",
		"Square packed with custard, sealed by burnt caramel",
		"Shortbread with marrow hidden, topped with cursed frosting",
		"Gingerbread stuffed with custard, icing across their limbs",
		"A skull with jam filling and caramel dripping through the cracks"
	],
	4: [ # Filling + Topping + Decoration
		"Round with jam, sugar glaze, and sprinkles on top",
		"A heart with cream, royal icing, and runes etched deep",
		"Shortbread hiding custard, cursed frosting above, eyes staring back",
		"Square biscuit with marrow inside, burnt caramel, and a tongue laid across",
		"Gingerbread with jam, sugar glaze, and sprinkles to hide the cracks",
		"Skull biscuit stuffed with cream, caramel glaze, and eyes in its sockets"
	],
	5: [ # Witch speaks in riddles, twisted logic required
		"Round or short, filled with red that drips like truth, crown it sweet, and let it see.",
		"A vessel of love, yet rotten inside, dress it bright, but mark it with secrets.",
		"Four corners, yet no escape, soft within, gilded above, with a mouth to taste your lies.",
		"Short and plain, creamy but never alone, let its glaze blind, and its eyes accuse.",
		"Shaped like a man, but hollow of soul, let its insides bleed, its surface burn, and its tongue speak.",
		"A grinning face, marrow for thought, frost it cursed, etch it deep, and let it whisper back.",
	],
	6: [ # Final madness - the Witch unravels
		"All biscuits are one… their shells lie, their fillings scream. Frost them. Mark them. Feed me.",
		"Love is rot in sugar’s guise, choose a shape that once meant heart, and drown it in pale custard, fire, and watching eyes.",
		"A circle? A hole? A mouth that feeds itself, fill it with marrow, curse its skin, let the runes speak backwards.",
		"Four walls, no escape, sweet blood inside, glazed with lies, and a tongue that tastes your fear.",
		"He once danced… now he crumbles, cream in his belly, royal crown upon his head, and ash-like sprinkles as snow.",
		"Skull or chalice? I forget, stuff it with thought, let caramel weep, and eyes stare where no one looks.",
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
	game_manager.game_over.connect(_on_game_over)


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

		if game_manager.biscuit_broke or not game_manager.valid_biscuit or game_manager.player_died:
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

	game_manager.biscuit_validator.set_instructions(_round, instructions_index)
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
		"Breaking before baking?!?",
		"Pathetic. Even dough is stronger than you.",
		"Do you think shattered crumbs will satisfy me?",
		"The biscuit broke… perhaps your bones will hold better.",
		"Every failure is a crack in YOUR skin, not the dough.",
		"The heat is wasted… the hunger grows.",
		"Did you drop it on purpose? Are you begging for punishment?",
		"You disappoint the recipe… and me.",
		"The tray weeps with your weakness.",
		"Another broken batch? The oven whispers your name.",
		"Flawed. Fragile. Foolish. Like you.",
		"The biscuit crumbled… next, your will shall too."
	]

	say_message(broken_messages.pick_random())


func _on_biscuit_invalid() -> void:
	await game_manager.game_camera.animation_player.animation_finished

	var invalid_message: Array[String] = [
		"That's not what I told you to make.",
		"Can you not follow simple instructions?!",
		"What did you think I asked for?",
		"Follow my directions… or die.",
		"You did not listen to meeeeeeee!",
		"The oven hungers… it will taste you if you disobey again.",
		"Wrong. Wrong! Wrong! I gave you the recipe, and you spat on it!",
		"Are you deaf, or just deliciously stupid?",
		"What did you think I asked for, not… whatever THIS is.",
		"Every mistake is another step closer to the oven.",
		"Not what I asked for. Not what I wanted. Not what I’ll forgive.",
		"The recipe rejects your defiance.",
		"Defy me again, and I’ll frost your corpse instead."
	]

	say_message(invalid_message.pick_random())


func _on_game_over() -> void:
	game_manager.game_camera.view_witch()
	await game_manager.game_camera.animation_player.animation_finished

	say_message("GAME OVER, GOOD DAY, YOU DIED")
