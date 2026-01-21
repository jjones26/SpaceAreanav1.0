extends Node3D

@export_group("Spawn Settings")
@export var enemy_scene: PackedScene
@export var max_enemies: int = 20
@export var initial_spawn_interval: float = 3.0
@export var minimum_interval: float = 0.5  # Fastest it can spawn
@export var ramp_up_speed: float = 0.05    # How much faster it gets per spawn

@export_group("Wave Settings")
@export var active_duration: float = 30.0  # Seconds of spawning
@export var break_duration: float = 10.0   # Seconds of resting
@export var auto_start: bool = true

var spawners: Array[Node3D] = []
var current_enemies: int = 0
var current_interval: float
var is_on_break: bool = false

@onready var state_timer: Timer = Timer.new()
@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	current_interval = initial_spawn_interval
	
	# Setup Spawners
	for child in get_children():
		if child is Node3D:
			spawners.append(child)
			
	if enemy_scene == null or spawners.is_empty():
		push_error("Spawn Manager misconfigured!")
		return

	# Setup Timers
	add_child(state_timer)
	add_child(spawn_timer)
	
	state_timer.timeout.connect(_toggle_break)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	if auto_start:
		start_spawning()

func start_spawning():
	is_on_break = false
	state_timer.start(active_duration)
	spawn_timer.start(current_interval)

func _toggle_break():
	is_on_break = !is_on_break
	if is_on_break:
		print("Starting Break Phase...")
		state_timer.start(break_duration)
		spawn_timer.stop()
	else:
		print("Starting Active Phase...")
		state_timer.start(active_duration)
		spawn_timer.start(current_interval)

func _on_spawn_timer_timeout():
	if current_enemies < max_enemies:
		spawn_enemy()
		# Ramp up the speed
		current_interval = max(minimum_interval, current_interval - ramp_up_speed)
	# Restart timer with new (potentially faster) interval
	spawn_timer.start(current_interval)

func spawn_enemy() -> void:
	var spawner = spawners.pick_random()
	var enemy = enemy_scene.instantiate()
	# Add to main scene tree
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawner.global_position
	current_enemies += 1
	enemy.tree_exited.connect(func(): current_enemies -= 1)
	
