extends Node3D

@export var player: Node3D

@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var health := 100
var time := 0.0
var target_position: Vector3
var destroyed := false
signal died
#movement
@export var move_speed := 3.0
@export var hover_strength := 1.0

# When ready, save the initial position

func _ready():
	target_position = global_position


func _process(delta):
	if player == null:
		return
	self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
	
	#move towards player
	var direction = (player.global_position - global_position).normalized()
	var distance = global_position.distance_to(player.global_position)
	if distance > 2.0:
		target_position += direction * move_speed * delta
	
	target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
	time += delta
	position = target_position


func _post_spawn_setup(spawn_position: Vector3, player_ref: Node3D):
	global_position = spawn_position
	player = player_ref
	died.connect(_on_died_safe)

func _on_died_safe():
	pass


# Take damage from player

func damage(amount):
	Audio.play("sounds/enemy_hurt.ogg")
	health -= amount
	if health <= 0 and !destroyed:
		destroy()

# Destroy the enemy when out of health

func destroy():
	if destroyed:
		return
	Audio.play("sounds/enemy_destroy.ogg")
	died.emit()
	destroyed = true
	queue_free()
# Shoot when timer hits 0

func _on_timer_timeout():
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("damage"):  # Raycast collides with player
			
			# Play muzzle flash animation(s)
			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)
			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)
			Audio.play("sounds/enemy_attack.ogg")
			collider.damage(5)  # Apply damage to player
