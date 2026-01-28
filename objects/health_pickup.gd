extends Area3D


signal picked_up

@export var heal_amount: int = 15
@onready var pickup_sfx: AudioStreamPlayer3D = $PickupSFX
@onready var pickup_health: MeshInstance3D = $RootNode/Pickup_Health
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@export var rotation_speed: float = 1.0 


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	pickup_health.rotate_y(rotation_speed * delta)


func _on_body_entered(body: Node) -> void:
	if body.has_method("heal"):
		picked_up.emit()
		pickup_health.visible = false
		pickup_sfx.play()
		collision_shape_3d.set_deferred("disabled", true)
		body.heal(heal_amount)
		await pickup_sfx.finished
		queue_free()
