extends Node3D


@export var enemy_scene: PackedScene
@export var max_enemies: int = 15
@export var spawn_interval: float = 3.0

var spawners: Array[Node3D] = []
var current_enemies: int = 0


func _ready() -> void:
	# Cache all child spawners
	for child in get_children():
		if child is Node3D:
			spawners.append(child)
	# Safety check
	if enemy_scene == null:
		push_error("EnemySpawnManager: enemy_scene not assigned.")
		return
	if spawners.is_empty():
		push_error("EnemySpawnManager: no spawner nodes found.")
		return
	call_deferred("start_spawning")


func start_spawning() -> void:
	spawn_loop()


func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		if current_enemies >= max_enemies:
			continue
		spawn_enemy()


func spawn_enemy() -> void:
	var spawner: Node3D = spawners.pick_random()
	if not spawner.is_inside_tree():
		return
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	print("Enemy parent before add:", enemy.get_parent())
	enemy.global_position = spawner.global_position
	current_enemies += 1
	# Ensure enemy count stays correct when it dies or is freed
	enemy.tree_exited.connect(func():
		current_enemies -= 1)
