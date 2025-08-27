class_name Biscuit
extends RigidBody3D

signal filling_added()
signal topping_added()

var is_placed: bool = false
var is_spreading: bool = false
var topping_mesh: MeshInstance3D
var topping_material: ShaderMaterial

var dissolve_value: float = 1.5

@onready var topping: Node3D = $Topping
@onready var game_manager: GameManager = get_tree().get_first_node_in_group("GameManager")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	topping_mesh = topping.get_child(0)
	topping_material = topping_mesh.material_override.duplicate()
	topping_mesh.material_override = topping_material


func _physics_process(delta: float) -> void:
	if is_zero_approx(linear_velocity.length()) and not is_placed:
		print("Biscuit Placed")
		is_placed = true
		game_manager.biscuit_placed.emit(self)

	if is_spreading:
		dissolve_value -= 0.33 * delta
		topping_material.set_shader_parameter("dissolveSlider", dissolve_value)

		if dissolve_value <= 0.0 :
			is_spreading = false
			topping_added.emit()


func add_filling() -> void:
	scale = Vector3(1.25, 1.25, 1.25)
	await get_tree().create_timer(0.33).timeout
	filling_added.emit()


func add_topping(topping: String) -> void:
	match topping:
		"Sugar":
			topping_material.set_shader_parameter("baseColor", Color.WHITE)
		"Icing":
			topping_material.set_shader_parameter("baseColor", Color.DARK_RED)
		"Frosting":
			topping_material.set_shader_parameter("baseColor", Color.MEDIUM_PURPLE)
		"Caramel":
			topping_material.set_shader_parameter("baseColor", Color.SADDLE_BROWN)

	is_spreading = true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("tray") or body.get_parent().is_in_group("tray"):
		reparent(body)
	if body is D6 :
		body.apply_central_force((body.global_position-global_position).normalized()*50)
