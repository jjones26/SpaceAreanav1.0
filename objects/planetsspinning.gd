extends MeshInstance3D

@export var rotation_speed: float = 0.1

@export var rotation_axis: Vector3 = Vector3.UP
# Default: spin around Y axis

func _process(delta: float) -> void:
	rotate(rotation_axis.normalized(), rotation_speed * delta)
