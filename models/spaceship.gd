extends Node3D

@export var target: Node3D
@export var offset := Vector3(0, 4.5, -6)
@export var follow_speed := 5.0

func _process(delta):
	if target == null:
		return

	var desired_pos = target.global_transform.origin + offset
	global_transform.origin = global_transform.origin.lerp(
		desired_pos,
		follow_speed * delta
	)

	look_at(target.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad(180))
	rotate_x(deg_to_rad(55))
