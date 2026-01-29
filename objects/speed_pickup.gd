extends Area3D

signal picked_up

@export var speed_multiplier: float = 1.25
@export var rotation_speed: float = 2.0 

@onready var pickup_sfx: AudioStreamPlayer3D = $PickupSFX
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var root_node: Node3D = $"Root Scene/RootNode"
@onready var pickup_thunder: MeshInstance3D = $"Root Scene/RootNode/Pickup_Thunder"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	pickup_thunder.rotate_y(rotation_speed * delta)

func _on_body_entered(body: Node) -> void:
	if body.has_method("upgrade_speed"):
		picked_up.emit()
		collision_shape.set_deferred("disabled", true)
		pickup_thunder.visible = false
		pickup_sfx.play()
		# Apply the permanent boost
		body.upgrade_speed(speed_multiplier)
		# Wait for sound to finish before deleting the object
		await pickup_sfx.finished
		queue_free()
