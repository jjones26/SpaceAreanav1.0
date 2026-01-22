extends Node3D


signal wave_changed(wave_number: int)
signal state_changed(is_break: bool, time_left: float)

@export_group("Spawn Settings")
@export var enemy_scene: PackedScene
@export var base_max_enemies: int = 10    # Starting enemies for Wave 1
@export var enemies_per_wave: int = 5     # How many more enemies each wave
@export var initial_spawn_interval: float = 3.0
@export var minimum_interval: float = 0.5
@export var ramp_up_speed: float = 0.05

@export_group("Wave Settings")
@export var active_duration: float = 30.0
@export var break_duration: float = 10.0
@export var auto_start: bool = true
@export var intro_delay: float = 12.0 

var spawners: Array[Node3D] = []
var current_enemies: int = 0
var current_max_enemies: int = 0
var current_interval: float
var current_wave: int = 0
var is_on_break: bool = false

@onready var state_timer: Timer = Timer.new()
@onready var spawn_timer: Timer = Timer.new()

func _ready() -> void:
	current_interval = initial_spawn_interval
	current_max_enemies = base_max_enemies
	# Setup Spawners
	for child in get_children():
		if child is Node3D:
			spawners.append(child)
	if enemy_scene == null or spawners.is_empty():
		push_error("Spawn Manager misconfigured! Check Scene and Spawners.")
		return
	# Setup Timers
	add_child(state_timer)
	add_child(spawn_timer)
	state_timer.timeout.connect(_toggle_break)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if auto_start:
		if intro_delay > 0:
			print("Waiting for intro audio: ", intro_delay, " seconds...")
			get_tree().create_timer(intro_delay).timeout.connect(start_new_wave)
		else:
			start_new_wave()

func start_new_wave():
	current_wave += 1
	is_on_break = false
	# Increase difficulty
	current_max_enemies = base_max_enemies + ((current_wave - 1) * enemies_per_wave)
	# Notify UI
	wave_changed.emit(current_wave)
	state_changed.emit(false, active_duration)
	print("Starting Wave ", current_wave, " - Max Enemies: ", current_max_enemies)
	state_timer.start(active_duration)
	spawn_timer.start(current_interval)

func _toggle_break():
	is_on_break = !is_on_break
	if is_on_break:
		print("Wave Complete! Starting Break Phase...")
		state_changed.emit(true, break_duration)
		state_timer.start(break_duration)
		spawn_timer.stop()
	else:
		start_new_wave()

func _on_spawn_timer_timeout():
	if current_enemies < current_max_enemies:
		spawn_enemy()
		# Ramp up the speed
		current_interval = max(minimum_interval, current_interval - ramp_up_speed)
	# Only restart spawn timer if not on break
	if not is_on_break:
		spawn_timer.start(current_interval)

func spawn_enemy() -> void:
	var spawner = spawners.pick_random()
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawner.global_position
	current_enemies += 1
	# Connect to tree_exited to track when enemies die
	enemy.tree_exited.connect(func(): current_enemies -= 1)
	
