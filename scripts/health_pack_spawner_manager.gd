extends Node3D

@export var health_pack_scene: PackedScene
@export var respawn_time: float = 30.0

func _ready() -> void:
	for child in get_children():
		if child is Node3D:
			spawn_at_point(child)

func spawn_at_point(spawn_node: Node3D) -> void:
	if health_pack_scene == null:
		return
		
	var pack = health_pack_scene.instantiate()
	pack.position = spawn_node.global_position
	get_tree().current_scene.add_child.call_deferred(pack)
	pack.picked_up.connect(_on_pack_collected.bind(spawn_node))

func _on_pack_collected(spawn_node: Node3D) -> void:
	await get_tree().create_timer(respawn_time).timeout
	spawn_at_point(spawn_node)
