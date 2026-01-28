extends Area3D


@export var launch_force: float = 25.0


func _on_body_entered(body):
	if body is CharacterBody3D:
		body.velocity.y = 0
		body.velocity.y += launch_force
	if body.is_on_floor():
		body.position.y += 0.1
