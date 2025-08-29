class_name ChatInstructions
extends RichTextLabel

signal instructions_done()

@export var timer_to_speak: float = 2.0

var playing_cutscene: bool = false

# BASE: Shortbread, Heart, Round, Gingerbread, Square, Skull
# FILLINGS: Jam, Cream, Custard, Marrrow
# TOPPINGS: Sugar, Icing, Frosting, Caramel
# DECORATIONS: Sprinkles, Tongue, Runes, Eyes

var dialogue_by_round: Dictionary = {
	1: [ # Filling only
		"Something simple, a shortbread filled with jam",
		"Bake me a heart, filled with cream",
		"Cut a round biscuit with a custard core",
		"Make a gingerbread person that has bones filled with marrow",
		"Craft a perfect square, covered with jam",
		"A skull overflowing with marrow",
	],
	2: [ # Filling + Topping
		"Now, fill a shortbread with custard topped with sugar and decorated with anything",
		"Create a creamy heart with royal icing decorated as you choose",
		"Round biscuit filled with marrow and curse its topping decorated any way",
		"Fill a squared shape with jam and topped with burnt caramel with any decoration",
		"A gingerbread stuffed with cream and glazed with sugar, decorated however you like",
		"A skull of jam and cursed frosting with any decoration",
	],
	3: [ # Filling + Topping + Decoration
		"A shortbread with cream, sugar, and sprinkles",
		"A heart filled with custard, iced, with sprinkles",
		"Round marrow, frosted in curses, etched with runes",
		"A square of jam, burnt with caramel, and a tongue to taste",
		"Gingerbread with cream, sugar glaze, and watching eyes",
		"Skull with custard, cursed frosting, and eyes that stare",
	],
	4: [ # 2 Filling / 2 Topping
		"Make it round, with cream or jam, sugar or caramel",
		"A shortbread packed with custard or marrow, topped with icing or caramel",
		"Heart that bleeds with jam or cream, cursed frosting or sugar glaze",
		"Gingerbread stuffed with marrow or custard, sugar or caramel on top",
		"Square with cream or jam, iced or cursed",
		"Skull of marrow or jam, dropped with caramel or sugar",
	],
	5: [ # 2 Filling / 2 Topping / 1 Decoration
		"Round or Short, bleeding with jam or cream, dripping with sugar or caramel, that watches with eyes",
		"Any bodypart, with marrow that’s cursed or burnt, with runes across its surface",
		"4 corners, a filling that starts with C, frosted or iced, that can taste",
		"A person or skull, jam filled, royal or glazed, that blinks",
		"Round or Square, make it with marrow or jam, anything sweet, sprinkled with treats",
	],
	6: [ # Final madness
		"All shapes blur together, fill them, top them, decorate them, they all taste the same",
		"Square heart, a filling with C and a topping made from something sweet",
		"Circle shape, leaking bone juice, that’s shivering cold",
		"A person or star, filled with whatever, that’s burnt or has a crown",
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
	game_manager.victory.connect(_on_victory)


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

		if game_manager.biscuit_broke or not game_manager.valid_biscuit or \
		 game_manager.player_died or playing_cutscene:
			await get_tree().create_timer(2.0).timeout

		instructions_done.emit()


func new_instructions() -> void:
	text = ""

	var _round: int = game_manager.round
	if _round >= 7:
		_round = randi_range(2, 6)
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
		"Pathetic. Even dough is stronger than you",
		"Do you think shattered crumbs will satisfy me?",
		"The biscuit broke… perhaps your bones will hold better",
		"Every failure is a crack in YOUR skin, not the dough",
		"The heat is wasted… the hunger grows",
		"Did you drop it on purpose? Are you begging for punishment?",
		"You disappoint the recipe… and me",
		"The tray weeps with your weakness",
		"Another broken batch? The oven whispers your name",
		"Flawed. Fragile. Foolish. Like you",
		"The biscuit crumbled… next, your will shall too"
	]

	say_message(broken_messages.pick_random())


func _on_biscuit_invalid() -> void:
	await game_manager.game_camera.animation_player.animation_finished

	var invalid_message: Array[String] = [
		"That's not what I told you to make",
		"Can you not follow simple instructions?!",
		"What did you think I asked for?",
		"Follow my directions… or die",
		"You did not listen to meeeeeeee!",
		"The oven hungers… it will taste you if you disobey again",
		"Wrong. Wrong! Wrong! I gave you the recipe, and you spat on it!",
		"Are you deaf, or just deliciously stupid?",
		"What did you think I asked for, not… whatever THIS is",
		"Every mistake is another step closer to the oven",
		"Not what I asked for. Not what I wanted. Not what I’ll forgive",
		"The recipe rejects your defiance",
		"Defy me again, and I’ll frost your corpse instead"
	]

	say_message(invalid_message.pick_random())


func _on_game_over() -> void:
	game_manager.game_camera.view_witch()
	await game_manager.game_camera.animation_player.animation_finished

	say_message("GAME OVER, GOOD DAY, YOU DIED")


func cutscene_1() -> void:
	playing_cutscene = true
	var quips: Array[String] = [
		"Ah, a crumb of progress. Don't choke on it",
		"You think a third of the way means you're clever? The oven laughs louder than you",
		"Mmm… the scent of hope. Almost as sweet as burnt sugar",
		"One step closer, but you still belong to my kitchen",
		"Even the weakest dough rises eventually…",
		"A third free? That's like half-baked bread. Useless",
		"Careful. Freedom smells delicious, but it's poison if undercooked",
	]

	say_message(quips.pick_random())


func cutscene_2() -> void:
	playing_cutscene = true
	var quips: Array[String] = [
		"No, no, no! You weren’t supposed to get this far",
		"Half-burned and half-gone… I’ll scorch the rest of you",
		"The dough squirms in your hands, but it was meant for me!",
		"Two-thirds free? Then two-thirds of you must die",
		"The oven grows restless. It wants more than biscuits now…",
		"You will never taste freedom. Only ash",
		"Why won’t you break like the others did?",
		"Careful, little baker. Every step forward costs you flesh",
	]

	say_message(quips.pick_random())


func cutscene_fear() -> void:
	playing_cutscene = true
	var quips: Array[String] = [
		"Half-broken already… how much longer until you crumble?",
		"I can smell the fear baking off you… sweeter than sugar",
		"Only halfway gone? I thought you'd break faster",
		"The oven doesn't just cook biscuits, it roasts your soul",
		"Your hands shake like dough that refuses to rise",
		"Every mistake feeds me, and you're starting to look delicious",
		"You're halfway done… not with the biscuits, with yourself",
		"Keep trembling, little baker. It seasons the marrow nicely",
	]

	say_message(quips.pick_random())


func _on_victory() -> void:
	playing_cutscene = true
	var victory: Array[String] = [
		"NO! The last crumb is MINE!",
		"Run, but the oven's fire will follow you into the dark",
		"Freedom? There is no freedom. Only hunger eternal!",
		"The kitchen collapses, the recipe burns, and still you run! COWARD!",
		"Leave, then. But you'll always taste of me",
	]

	say_message(victory.pick_random())
