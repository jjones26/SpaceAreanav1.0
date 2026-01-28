extends AnimatableBody3D

@export var movement_vector = Vector3(0, 5, 0) # Direction and distance
@export var speed = 2.0

var time = 0.0
@onready var start_position = position # Captures the position you set in the editor

func _physics_process(delta):
	time += delta * speed
	
	# Calculate the "swing" (0 to 1)
	var factor = (sin(time) + 1.0) / 2.0 
	
	# Move relative to the starting position
	position = start_position + (movement_vector * factor)
