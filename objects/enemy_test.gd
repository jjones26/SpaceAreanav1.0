extends CharacterBody3D

var player: Node3D

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
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if player == null or destroyed:
		return
	look_at(player.global_position + Vector3(0, 0.5, 0), Vector3.UP, true)
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var direction = to_player.normalized()
	# Horizontal movement
	if distance > 2.0:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = 0
		velocity.z = 0
	# Vertical pursuit + hover
	velocity.y = clamp(direction.y, -1.0, 1.0) * move_speed
	time += delta
	velocity.y += cos(time * 5.0) * hover_strength
	move_and_slide()




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
	GameManager.add_score(1)
	GameManager.add_crowd(5.0)
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
