extends Node3D

@export var flyby_ship_scenes: Array[PackedScene]


@export var spawn_interval: float = 3.5
@export var spawn_radius: float = 250.0
@export var min_height: float = 40.0
@export var max_height: float = 120.0

@export var min_speed: float = 30.0
@export var max_speed: float = 50.0

@export var min_lifetime: float = 15.0
@export var max_lifetime: float = 25.0

var _timer := 0.0

func _process(delta: float) -> void:
	if flyby_ship_scenes.is_empty():
		return
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_flyby()

func _spawn_flyby() -> void:
	var scene = flyby_ship_scenes.pick_random()
	var ship = scene.instantiate()
	add_child(ship)
	var radius = randf_range(120.0, 220.0)
	var angle = randf() * TAU
	var pos = Vector3(cos(angle), 0, sin(angle)) * radius
	pos.y = randf_range(60.0, 140.0)
	ship.global_position = global_position + pos
	var tangent = Vector3(-sin(angle), 0, cos(angle))
	tangent.y = randf_range(-0.15, 0.15)
	ship.look_at(ship.global_position + tangent, Vector3.UP)
	ship.speed = randf_range(min_speed, max_speed)
	ship.lifetime = randf_range(min_lifetime, max_lifetime)
