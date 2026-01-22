extends AudioStreamPlayer3D


@export var sfx_list: Array[AudioStream] 

@export var min_wait_time: float = 20.0
@export var max_wait_time: float = 40.0

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	setup_next_sound()

func setup_next_sound() -> void:
	var next_time = randf_range(min_wait_time, max_wait_time)
	timer.start(next_time)
	print("Next sound in: ", next_time, " seconds")

func _on_timer_timeout() -> void:
	if sfx_list.size() > 0:
		stream = sfx_list.pick_random()
		play()
	setup_next_sound()
