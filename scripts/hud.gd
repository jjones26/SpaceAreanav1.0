extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel
@onready var wave_label: Label = $WaveLabel
@onready var crowd_bar: TextureProgressBar = $CrowdMeter
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var enemies_remaining_label: Label = $EnemiesRemainingLabel

var spawner_ref: Node3D = null
var flash_tween: Tween
var is_counting_down: bool = false
var countdown_time: float = 0.0
var crowd_tween: Tween

func _on_health_updated(health):
	$Health.text = str(health) + "%"
	health_bar.value = health
	if health <= 25:
		health_bar.tint_progress = Color.RED
	else:
		health_bar.tint_progress = Color.WHITE

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
	GameManager.crowd_meter_changed.connect(_on_crowd_updated)
	crowd_bar.max_value = GameManager.MAX_CROWD
	crowd_bar.value = GameManager.crowd_value
	var spawner = get_tree().current_scene.find_child("EnemySpawnManager", true, false)
	if spawner:
		spawner_ref = spawner
		spawner.wave_changed.connect(_update_wave_display)
		spawner.state_changed.connect(_on_spawner_state_changed)
		spawner.enemies_remaining_changed.connect(_on_enemies_remaining_changed)
		_update_wave_display(spawner.current_wave)
		_on_enemies_remaining_changed(spawner.base_max_enemies)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		#player.health_updated.connect(_on_health_updated)
		health_bar.max_value = player.max_health
		_on_health_updated(player.health)
	high_score_label.text = "High Score: " + str(GameManager.high_score)
	score_label.text = "Eliminations: " + str(GameManager.score)


func _on_enemies_remaining_changed(count: int):
	if enemies_remaining_label:
		enemies_remaining_label.text = "Enemies Left: " + str(count)
		# Make the label "pulse" slightly when someone dies (optional juice)
		var pulse = create_tween()
		pulse.tween_property(enemies_remaining_label, "scale", Vector2(1.1, 1.1), 0.1)
		pulse.tween_property(enemies_remaining_label, "scale", Vector2(1.0, 1.0), 0.1)


func _update_wave_display(wave_number: int):
	wave_label.text = "WAVE: " + str(wave_number)
	stop_flashing()
	is_counting_down = false # Stop the timer display

func _on_spawner_state_changed(is_break: bool, time_left: float):
	if is_break:
		countdown_time = time_left
		is_counting_down = true
		start_flashing()
		enemies_remaining_label.hide()
		#var spawner = get_tree().current_scene.find_child("EnemySpawnManager", true, false)
		
		if spawner_ref and spawner_ref.current_wave == 0:
			wave_label.text = "GET READY!"
	else:
		is_counting_down = false
		enemies_remaining_label.show()
		#var spawner = get_tree().current_scene.find_child("EnemySpawnManager", true, false)
		if spawner_ref:
			wave_label.text = "WAVE: " + str(spawner_ref.current_wave)
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


func _on_crowd_updated(new_value: float):
	if crowd_tween:
		crowd_tween.kill()
	crowd_tween = create_tween()
	crowd_tween.tween_property(crowd_bar, "value", new_value, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if new_value >= GameManager.MAX_CROWD:
		_on_crowd_maxed()


func _on_crowd_maxed():
	print("CROWD IS GOING WILD!")
