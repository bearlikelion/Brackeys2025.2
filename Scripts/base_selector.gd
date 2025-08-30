class_name BaseSelector
extends MarginContainer

signal base_selected(selected_base: String)
signal bases_hidden()


@onready var ui_3d: ui_3d = $".."


var lerp_visible: bool = false
var lerp_invisible: bool = false
var is_selected: bool = false

@onready var grid_container: GridContainer = %GridContainer
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")
@export var tween_speeed : float


func _ready() -> void:
	modulate.a = 0
	if game_manager != null :
		game_manager.base_selector = self
		for button: Button in grid_container.get_children():
			button.pressed.connect(_on_base_selected.bind(button.name))


#func _process(delta: float) -> void:
	#if lerp_visible:
		#lerp_visible = false
		#var tween = self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		#tween.tween_property(self,"modulate:a",1.0,0.5).from(1.0).connect("finished",show_bases)
		##modulate.a = lerp(modulate.a, 1.0, 1.5 * delta)
		##if modulate.a == 1.0:
			##lerp_visible = false
#
	#if lerp_invisible:
		#lerp_invisible = false
		#var tween = self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
		#tween.tween_property(self,"modulate:a",0.0,0.5).from(1.0).connect("finished",set_hide)

func set_hide():
	lerp_invisible = false
	var tween = self.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",0.0,tween_speeed).from(1.0)
	#var tweengrid = grid_container.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	#tweengrid.tween_property(grid_container,"theme_override_constants/v_separation",200,tween_speeed).from(3)
	#var tweensize = self.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	#tweensize.tween_property(self,"size:y",800,tween_speeed).from(450)
	await tween.finished
	
	lerp_invisible = true
	bases_hidden.emit()
	hide()
	is_selected = false

func _on_base_selected(selected_base: String) -> void:
	if !is_selected :
		#disable_buttons(true)
		await ui_3d._animate_base_out(tween_speeed)
		base_selected.emit(selected_base)
		is_selected = true


func show_bases() -> void:
	Utils.shuffle_buttons(grid_container)
	#disable_buttons(false)
	lerp_visible = true
	show()
	var tween = self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self,"modulate:a",1.0,tween_speeed).from(0.0)
	await ui_3d._animate_base_in(tween_speeed)
	#var tweengrid = grid_container.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tweengrid.tween_property(grid_container,"theme_override_constants/v_separation",3,tween_speeed).from(200)
	#var tweensize = self.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tweensize.tween_property(self,"size:y",450,tween_speeed).from(800)
	lerp_visible = false


func hide_bases() -> void:
	lerp_visible = false
	lerp_invisible = true
	set_hide()


#func disable_buttons(is_disabled: bool) -> void:
	#for button: Button in grid_container.get_children():
		#button.disabled = is_disabled
