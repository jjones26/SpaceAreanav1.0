extends MeshInstance3D

@export var amplitude: float = 0.25
@export var speed: float = 10.0
@export var amplitude_variance: float = 0.3

var base_y: float
var time := 0.0
var final_amplitude: float

func _ready():
	base_y = global_position.y
	# Randomize jump height once
	final_amplitude = amplitude + randf_range(-amplitude_variance, amplitude_variance)
	# --- Randomize color per fan ---
	var mat := get_active_material(0)
	if mat:
		mat = mat.duplicate()             
		var color := Color.from_hsv(randf(), 0.7, 1.0)
		mat.albedo_color = color
		set_surface_override_material(0, mat)

func _process(delta):
	time += delta * speed
	var pos := global_position
	pos.y = base_y + sin(time) * final_amplitude
	global_position = pos
