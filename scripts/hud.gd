extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel


func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _process(_delta: float) -> void:
	$FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())


func _ready():
	GameManager.score_changed.connect(_on_score_updated)
	GameManager.high_score_changed.connect(_on_high_score_updated)
	high_score_label.text = "High Score: " + str(GameManager.high_score)
	score_label.text = "Eliminations: " + str(GameManager.score)


func _on_high_score_updated(new_high):
	high_score_label.text = "High Score: " + str(new_high)


func _on_score_updated(new_score):
	score_label.text = "Eliminations: " + str(new_score)
