extends Node3D

signal wave_changed(wave_number: int)
signal state_changed(is_break: bool, time_left: float)
signal enemies_remaining_changed(count: int)

@export_group("Spawn Settings")
@export var enemy_scene: PackedScene
@export var base_max_enemies: int = 10     # Total enemies for Wave 1
@export var enemies_per_wave: int = 5      # How many more enemies each wave
@export var initial_spawn_interval: float = 3.0
@export var minimum_interval: float = 0.5
@export var ramp_up_speed: float = 0.05

@export_group("Wave Settings")
@export var break_duration: float = 10.0
@export var auto_start: bool = true
@export var intro_delay: float = 12.0 

var spawners: Array[Node3D] = []
var current_enemies_alive: int = 0
var enemies_spawned_this_wave: int = 0
var current_max_enemies: int = 0
var current_interval: float
var current_wave: int = 0
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
		push_error("Spawn Manager misconfigured! Check Scene and Spawners.")
		return
		
	# Setup Timers
	add_child(state_timer)
	add_child(spawn_timer)
	
	state_timer.one_shot = true
	spawn_timer.one_shot = true
	
	state_timer.timeout.connect(_on_break_finished)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	if auto_start:
		if intro_delay > 0:
			print("Waiting for intro: ", intro_delay, "s")
			get_tree().create_timer(intro_delay).timeout.connect(start_new_wave)
		else:
			start_new_wave()

func start_new_wave() -> void:
	current_wave += 1
	is_on_break = false
	enemies_spawned_this_wave = 0
	current_enemies_alive = 0
	
	# Linear difficulty scaling
	current_max_enemies = base_max_enemies + ((current_wave - 1) * enemies_per_wave)
	current_interval = initial_spawn_interval
	# Notify UI
	wave_changed.emit(current_wave)
	enemies_remaining_changed.emit(current_max_enemies)
	state_changed.emit(false, 0) # 0 means "Active Combat"
	print("Starting Wave ", current_wave, " - Total Enemies: ", current_max_enemies)
	spawn_timer.start(current_interval)

func _on_spawn_timer_timeout() -> void:
	if is_on_break: return

	if enemies_spawned_this_wave < current_max_enemies:
		spawn_enemy()
		# Speed up the next spawn
		current_interval = max(minimum_interval, current_interval - ramp_up_speed)
		spawn_timer.start(current_interval)
	else:
		print("All enemies for wave ", current_wave, " have been dispatched. Waiting for clear...")

func spawn_enemy() -> void:
	var spawner = spawners.pick_random()
	var enemy = enemy_scene.instantiate()
	# Ensure enemy is added to the scene tree
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawner.global_position
	current_enemies_alive += 1
	enemies_spawned_this_wave += 1
	# Track when the enemy is killed/removed
	enemy.tree_exited.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	current_enemies_alive -= 1
	# Calculate total remaining (alive + yet to spawn)
	var remaining_to_kill = (current_max_enemies - enemies_spawned_this_wave) + current_enemies_alive
	enemies_remaining_changed.emit(remaining_to_kill)
	# Check if wave is totally cleared
	if current_enemies_alive <= 0 and enemies_spawned_this_wave >= current_max_enemies:
		start_break_phase()

func start_break_phase() -> void:
	is_on_break = true
	spawn_timer.stop()
	print("Wave Clear! Break starting for ", break_duration, "s")
	state_changed.emit(true, break_duration)
	state_timer.start(break_duration)

func _on_break_finished() -> void:
	start_new_wave()
