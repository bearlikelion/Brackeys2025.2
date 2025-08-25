class_name D6
extends RigidBody3D

signal roll_result(face_number: int, type: String, die_name: String)

var dice_power = 400
var roll_strength: int = randi_range(1, 5)

var die_name: String
var kind: String
var dissolve: bool = false
var dissolve_value: float = 0.0
var dice_material: ShaderMaterial

var can_clack: bool = true
var time_accumulator: float = 0.0
var audio_interval: float = 1.0

var stuck_timer: float = 0.0
var stuck_threshold: float = 2.0
var min_movement_threshold: float = 0.1
var angle_tolerance: float = 0.75

@onready var ray_casts: Node = $RayCasts
@onready var dice: MeshInstance3D = $Mesh/Cube2
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	roll()
	dice_material = dice.material_override.duplicate()
	dice.material_override = dice_material


func _physics_process(delta: float) -> void:
	time_accumulator += delta

	if time_accumulator >= audio_interval:
		time_accumulator -= audio_interval
		can_clack = true

	if dissolve:
		dissolve_value += 0.33 * delta
		dice_material.set_shader_parameter("dissolveSlider", dissolve_value)

		if dissolve_value >= 1.5:
			queue_free()

	if not freeze:
		# Check if die is nearly stopped
		if linear_velocity.length() <= min_movement_threshold and angular_velocity.length() <= min_movement_threshold:
			stuck_timer += delta

			# Check if die has been stuck for too long
			if stuck_timer >= stuck_threshold:
				if not is_die_on_valid_face():
					# print("Die stuck at invalid angle - rerolling!")
					apply_central_impulse(Vector3.UP * 10.0 + Vector3(randf() - 0.5, 0, randf() - 0.5) * 3.0)
					angular_velocity = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5) * 5.0
					stuck_timer = 0.0
		else:
			# Die is moving normally - reset timer
			stuck_timer = 0.0

		# Check if die is settled on a valid face and nearly stopped
		if linear_velocity.length() <= 0.01 and angular_velocity.length() <= 0.01:
			if is_die_on_valid_face():
				linear_velocity = Vector3.ZERO
				angular_velocity = Vector3.ZERO
				freeze = true
				stuck_timer = 0.0
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
	if freeze:
		for raycast: DieRaycast in ray_casts.get_children():
			if raycast.is_colliding():
				print("Dice landed on %s" % raycast.opposite_side)
				roll_result.emit(raycast.opposite_side, kind, die_name)
				# dissolve = true

				if raycast.opposite_side == 1 or raycast.opposite_side == 2:
					dice_material.set_shader_parameter("edgeColor", Color.REBECCA_PURPLE)
				if raycast.opposite_side == 3 or raycast.opposite_side == 4:
					dice_material.set_shader_parameter("edgeColor", Color.ORANGE_RED)
				if raycast.opposite_side == 5 or raycast.opposite_side == 6:
					dice_material.set_shader_parameter("edgeColor", Color.DARK_GREEN)

				break


func is_die_on_valid_face() -> bool:
	# Get the die's up vector in world space
	var up_vector: Vector3 = global_transform.basis.y.normalized()

	# Define the six face normals of a die
	var face_normals: Array[Vector3] = [
		Vector3.UP, Vector3.DOWN,
		Vector3.LEFT, Vector3.RIGHT,
		Vector3.FORWARD, Vector3.BACK
	]

	# Check if any face normal is aligned with the up vector
	for normal in face_normals:
		var dot_product: float = abs(up_vector.dot(normal))
		# print("Dot Product: %s" % dot_product)
		if dot_product >= angle_tolerance:
			# Also verify with raycasts that we're actually touching ground
			for raycast: DieRaycast in ray_casts.get_children():
				if raycast.is_colliding():
					return true
			break

	return false


func _on_body_entered(body: Node) -> void:
	if body is D6:
		body.apply_central_force((global_position - body.global_position).normalized()*50)
		apply_central_force(Vector3.UP*dice_power)
		dice_power /= 4
	else:
		# print("Play Sound")
		if not audio_stream_player_3d.playing and can_clack:
			can_clack = false
			audio_stream_player_3d.pitch_scale += randf_range(-0.33, 0.33)
			audio_stream_player_3d.play()
