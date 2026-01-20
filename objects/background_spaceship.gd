extends Node3D

@export var speed: float = 40.0
@export var lifetime: float = 8.0
@export var drift: Vector3 = Vector3.ZERO
@export var rotate_speed: Vector3 = Vector3.ZERO

var _time_alive := 0.0

func _process(delta: float) -> void:
	_time_alive += delta
	translate_object_local(Vector3(0, 0, -speed * delta))
	global_position += drift * delta
	

	rotation += rotate_speed * delta

	if _time_alive >= lifetime:
		queue_free()
