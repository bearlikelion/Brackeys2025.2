class_name D6
extends RigidBody3D

var roll_strength: int = randi_range(10, 25)

@onready var ray_casts: Node = $RayCasts

func _ready() -> void:
	sleeping_state_changed.connect(_on_sleeping_state_changed)
	roll()


func _physics_process(delta: float) -> void:
	if linear_velocity == Vector3.ZERO and not sleeping:
		sleeping = true


func roll() -> void:
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Random Rotation
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2 * PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2 * PI)) * transform.basis

	var throw_vector: Vector3 = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throw_vector * roll_strength / 2
	linear_velocity = throw_vector * roll_strength
	apply_central_impulse(throw_vector * roll_strength)


func _on_sleeping_state_changed() -> void:
	if sleeping:
		for raycast: DieRaycast in ray_casts.get_children():
			if raycast.is_colliding():
				print("Roll landed on %s" % raycast.opposite_side)
