extends Node3D

@export var health_pack_scene: PackedScene
@export var spawn_time: float = 30.0

func _ready() -> void:
	_spawn_health_packs()
	_spawn_timer()

func _spawn_timer() -> void:
	while true:
		await get_tree().create_timer(spawn_time).timeout
		_spawn_health_packs()

func _spawn_health_packs() -> void:
	for spawner in get_children():
		if spawner is Node3D:
			var pack := health_pack_scene.instantiate()
			pack.global_transform = spawner.global_transform
			get_tree().current_scene.add_child.call_deferred(pack)
