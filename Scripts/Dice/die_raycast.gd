class_name DieRaycast
extends RayCast3D

@export var opposite_side: int

func _ready() -> void:
	add_exception(owner)
