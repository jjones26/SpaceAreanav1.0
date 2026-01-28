extends AnimatableBody3D

@export var distance = Vector3(0, 10, 0) # How far to move
@export var speed = 1.0
var time = 0.0

func _physics_process(delta):
	time += delta * speed
	# Use a sine wave to move back and forth smoothly
	var offset = (sin(time) + 1.0) / 2.0 
	position = distance * offset
