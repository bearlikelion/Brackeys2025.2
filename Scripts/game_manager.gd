class_name GameManager
extends Node3D

signal victory()
signal game_over()
signal round_started()
signal fear_increased()
signal fear_decreased()
signal biscuit_broken()
signal biscuit_invalid()
signal biscuit_placed(biscuit: Biscuit)

@export var obey_instructions: bool = true

var round: int = 1
var instruction_index: int = 0
var instructions_round: int = 0

var fear: int = 0
var total: int = 0
var score: int = 0

var dice_to_roll: int = 0
var biscuits_baked: int = 0

var dice: Array = []

var biscuit: Biscuit
var valid_biscuit: bool
var player_won: bool = false
var player_died: bool = false
var biscuit_broke: bool = false

var type: String
var filling: String
var topping: String
var decoration: String

var filling_score: int = 0

@onready var dice_scorer: DiceScorer = $DiceScorer
@onready var biscuit_validator: Node = $BiscuitValidator
@onready var dice_well: DiceWell = $OvenScene/DiceWell

@onready var type_label: Label = %TypeLabel
@onready var topping_label: Label = %ToppingLabel
@onready var filling_label: Label = %FillingLabel

@onready var score_label: Label = %ScoreLabel
@onready var dice_amount: Label = %DiceAmount
@onready var fear_label: Label = %FearLabel
@onready var score_progress: ProgressBar = %ScoreProgress
@onready var fear_progress: ProgressBar = %FearProgress

@onready var chat_instructions: ChatInstructions = %ChatInstructions
@onready var chat_message: MarginContainer = %ChatMessage

@onready var fear_sound: AudioStreamPlayer = $FearSound
@onready var score_sound: AudioStreamPlayer = $ScoreSound

@onready var game_camera: GameCamera = get_tree().get_first_node_in_group("GameCamera")
@onready var oven_scene: OvenScene = get_tree().get_first_node_in_group("OvenScene")

@onready var base_selector: BaseSelector :
	set(value):
		base_selector = value
		base_selector.base_selected.connect(_on_base_selected)


@onready var toppings_selector: ToppingsSelector:
	set(value):
		toppings_selector = value
		toppings_selector.filling_pressed.connect(_on_topping_pressed)
		toppings_selector.topping_pressed.connect(_on_topping_pressed)
		toppings_selector.decoration_pressed.connect(_on_topping_pressed)
		toppings_selector.toppings_selected.connect(_on_toppings_selected)


func _ready() -> void:
	biscuit_placed.connect(_on_biscuit_placed)
	dice_well.roll_result.connect(_on_roll_result)
	dice_well.roll_finished.connect(_on_roll_finished)
	chat_instructions.instructions_done.connect(_on_instructions_done)
	new_round()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("roll_new"):
		base_selector.show_bases()


func _on_roll_result(dice_face: int, dice_type: String, dice_name: String, dice_position: Vector3) -> void:
	if not biscuit_broke:
		dice_scorer.last_die_position = dice_position
		dice_scorer.score_die(dice_type, dice_name, dice_face)


func add_score(amount: int) -> void:
	if not biscuit_broke:

		if amount > 0 and not score_sound.playing:
			score_sound.pitch_scale = 1.0 + randf_range(-0.15, 0.25)
			score_sound.play()

		score += amount
		# score_label.text = "SCORE: %s" % str(score)
		score_progress.value = score

		dice_scorer.spawn_floating_number(amount, false)


func add_fear(amount: int) -> void:
	if amount > 0:
		fear_increased.emit()
		if not fear_sound.playing:
			fear_sound.pitch_scale = 1.0 + randf_range(-0.25, 0.25)
			fear_sound.play()
	else:
		fear_decreased.emit()

	fear += amount
	dice_scorer.spawn_floating_number(amount, true)

	if fear < 0:
		fear = 0

	# fear_label.text = "FEAR: %s" % str(fear)
	fear_progress.value = fear


func update_dice_count() -> void:
	if dice_to_roll < 0:
		dice_to_roll = 0

	dice_amount.text = "DICE TO ROLL: %s" % str(dice_to_roll)


func _on_instructions_done() -> void:
	if biscuit_broke or not valid_biscuit:
		new_round()
	elif player_died:
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	else:
		base_selector.show_bases()


func _on_base_selected(selected_base: String) -> void:
	base_selector.hide_bases()
	type = selected_base

	match type:
		"Shortbread":
			dice_to_roll += 1
		"Heart":
			dice_to_roll += 2
		"Round":
			dice_to_roll += 3
		"Square":
			dice_to_roll += 4
		"Gingerbread":
			dice_to_roll += 5
		"Skull":
			dice_to_roll += 6

	for dice_i: int in range(dice_to_roll):
		dice.append({"kind": "base", "name": type})

	type_label.text = "TYPE: %s" % selected_base
	oven_scene.add_biscuit(selected_base)

	await biscuit_placed
	await base_selector.bases_hidden
	toppings_selector.show_toppings()
	update_dice_count()


func _on_toppings_selected(_filling: String, _topping: String, _decoration: String) -> void:
	toppings_selector.hide_toppings()

	if _filling != "":
		filling = _filling
		dice.append({"kind": "filling", "name": filling})

	if _topping != "":
		topping = _topping
		dice.append({"kind": "topping", "name": topping})

	if _decoration != "":
		if _decoration != "Sprinkles" or _decoration != "Runes":
			decoration = _decoration
			dice.append({"kind": "decoration", "name": decoration})

		if _decoration == "Runes":
			dice_scorer.reroll_fail = true

	await toppings_selector.toppings_hidden

	if filling != "":
		biscuit.add_filling()
		await biscuit.filling_added

	if topping != "":
		biscuit.add_topping(topping)
		await biscuit.topping_added

	valid_biscuit = biscuit_validator.is_biscuit_valid(type, filling, topping, decoration)
	if valid_biscuit:
		print("NOW ROLL YOUR LUCK | DICE %s" % dice_to_roll)
		roll_dice()
	else:
		invalid_biscuit()


func roll_dice() -> void:
	chat_message.hide()
	dice_well.roll_dice(dice)
	update_dice_count()


func _on_topping_pressed(is_toggled: bool) -> void:
	if is_toggled:
		dice_to_roll += 1
	else:
		dice_to_roll -= 1
#
	update_dice_count()


func break_biscuit() -> void:
	biscuit_broken.emit()


func double_biscuit() -> void:
	print("2x SCORE!")
	if not biscuit_broke:
		add_score(score)


func _on_roll_finished() -> void:
	print("Roll Finished")
	if topping == "Sprinkles":
		dice_scorer.score_sprinkles_decoration()

	dice_scorer.reroll_fail = false
	dice_scorer.success_die = 0

	if biscuit_broke:
		game_camera.view_witch()
		await get_tree().create_timer(0.5).timeout
		var witch: Node3D = get_tree().get_first_node_in_group("witch")
		biscuit.apply_central_force(((witch.global_position + (Vector3.UP * 5)) - biscuit.global_position).normalized() * 400)
		biscuit.apply_torque(Vector3(randf(),randf(),randf()))
	else:
		game_camera.view_oven()
		await get_tree().create_timer(0.63).timeout
		var tray: CSGBox3D = get_tree().get_first_node_in_group("tray")
		var force_direction: Vector3 = ((tray.global_position + (Vector3.UP * 20)) - biscuit.global_position).normalized()
		force_direction.z += randf_range(-0.05, 0.05)
		biscuit.apply_central_force(force_direction * randf_range(450, 550))
		biscuit.apply_torque(Vector3(randf(), randf(), randf()))
		#var tween = biscuit.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		#tween.tween_property(biscuit,"global_position",tray.global_position,2).set_delay(2)


	#biscuit.queue_free()


func new_round() -> void:
	# Did player win?
	if score >= 150:
		player_won = true
		victory.emit()
		return

	# Is player dead?
	if fear >= 50:
		player_died = true
		game_over.emit()
		return

	round += 1
	biscuit_validator.reset()
	print("START ROUND: %s" % str(round))

	if game_camera.looking_at != game_camera.Viewing.TABLE:
		game_camera.view_table()
		await game_camera.animation_player.animation_finished

	chat_message.show()
	# base_selector.show()
	dice = []
	dice_to_roll = 0
	update_dice_count()

	type = ""
	filling = ""
	topping = ""
	decoration = ""

	biscuit = null
	valid_biscuit = true
	biscuit_broke = false
	chat_instructions.new_instructions()
	round_started.emit()


func invalid_biscuit() -> void:
	print("INVALID BISCUIT")
	valid_biscuit = false
	game_camera.view_witch()
	biscuit_invalid.emit()
	#biscuit.queue_free()
	add_fear(round + 1)
	await get_tree().create_timer(0.5).timeout
	var witch: Node3D = get_tree().get_first_node_in_group("witch")
	biscuit.apply_central_force(((witch.global_position + (Vector3.UP *5)) - biscuit.global_position).normalized()*400)
	biscuit.apply_torque(Vector3(randf(),randf(),randf()))


func _on_biscuit_placed(new_biscuit: Biscuit) -> void:
	biscuit = new_biscuit
