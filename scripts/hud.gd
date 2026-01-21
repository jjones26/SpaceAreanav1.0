extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var wave_label: Label = $WaveLabel

var flash_tween: Tween
var is_counting_down: bool = false
var countdown_time: float = 0.0

func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _process(delta: float) -> void:
	$FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Update the countdown text every frame if we are on break
	if is_counting_down:
		countdown_time -= delta
		var display_time = max(0, ceil(countdown_time))
		wave_label.text = "NEXT WAVE IN: " + str(display_time) + "s"

func _ready():
	GameManager.score_changed.connect(_on_score_updated)
	GameManager.high_score_changed.connect(_on_high_score_updated)
	
	var spawner = get_tree().current_scene.find_child("EnemySpawnManager", true, false)
	if spawner:
		spawner.wave_changed.connect(_update_wave_display)
		spawner.state_changed.connect(_on_spawner_state_changed)
		_update_wave_display(spawner.current_wave)
	
	high_score_label.text = "High Score: " + str(GameManager.high_score)
	score_label.text = "Eliminations: " + str(GameManager.score)

func _update_wave_display(wave_number: int):
	wave_label.text = "WAVE: " + str(wave_number)
	stop_flashing()
	is_counting_down = false # Stop the timer display

func _on_spawner_state_changed(is_break: bool, time_left: float):
	if is_break:
		countdown_time = time_left
		is_counting_down = true
		start_flashing()
	else:
		is_counting_down = false
		var spawner = get_tree().current_scene.find_child("EnemySpawnManager", true, false)
		if spawner:
			wave_label.text = "WAVE: " + str(spawner.current_wave)
		stop_flashing()

func start_flashing():
	if flash_tween:
		flash_tween.kill()
	flash_tween = create_tween().set_loops()
	flash_tween.tween_property(wave_label, "modulate", Color.YELLOW, 0.5)
	flash_tween.tween_property(wave_label, "modulate", Color.WHITE, 0.5)

func stop_flashing():
	if flash_tween:
		flash_tween.kill()
	wave_label.modulate = Color.WHITE

func _on_high_score_updated(new_high):
	high_score_label.text = "High Score: " + str(new_high)

func _on_score_updated(new_score):
	score_label.text = "Eliminations: " + str(new_score)
