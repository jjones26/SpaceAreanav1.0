extends Node

var high_score: int = 0
const SAVE_PATH = "user://highscore.save"

var score: int = 0
var crowd_value: float = 0.0
const MAX_CROWD: float = 100.0

signal score_changed(new_score)
signal high_score_changed(new_high_score)
signal crowd_meter_changed(new_value: float)


func _ready():
	load_high_score()
	

func _process(delta: float) -> void:
	#GameManager.add_crowd(-delta * .5)
	pass

func add_crowd(amount: float):
	crowd_value = clamp(crowd_value + amount, 0, MAX_CROWD)
	crowd_meter_changed.emit(crowd_value)

func reset_crowd():
	crowd_value = 0.0
	crowd_meter_changed.emit(crowd_value)


func add_score(amount: int):
	score += amount
	score_changed.emit(score)
	# Check if we beat the high score in real-time
	if score > high_score:
		high_score = score
		high_score_changed.emit(high_score)


func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_32(high_score)
	file.close()


func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		high_score = file.get_32()
		file.close()


func reset_score():
	score = 0
	score_changed.emit(score)
