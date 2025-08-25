extends Camera2D

var start_position
func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position ).normalized()
	var distince = global_position.distance_to(mouse_position)
	global_position = lerp(global_position,start_position+direction*distince*delta*10 , 5*delta)
