class_name D6
extends RigidBody3D

signal roll_result(face_number: int)

var roll_strength: int = randi_range(1, 5)

@onready var ray_casts: Node = $RayCasts


func _ready() -> void:
	roll()


func _physics_process(delta: float) -> void:
	if not freeze:
		# Check if die is settled on a face and nearly stopped
		if linear_velocity.length() <= 0.01 and angular_velocity.length() <= 0.01:
			# Check if any face is flat against the ground
			var is_on_face: bool = false
			for raycast: DieRaycast in ray_casts.get_children():
				if raycast.is_colliding():
					is_on_face = true
					break

			# Only stop if on a face
			if is_on_face:
				linear_velocity = Vector3.ZERO
				angular_velocity = Vector3.ZERO
				freeze = true
				sleeping = true
				detect_face()

		# Debug output
		#if linear_velocity.length() > 0.01 or angular_velocity.length() > 0.01:
			#print("LV: %s" % linear_velocity.length())
			#print("AV: %s" % angular_velocity.length())


func roll() -> void:
	freeze = false
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


func detect_face() -> void:
	if sleeping:
		for raycast: DieRaycast in ray_casts.get_children():
			if raycast.is_colliding():
				print("Dice landed on %s" % raycast.opposite_side)
				roll_result.emit(raycast.opposite_side)
				break
