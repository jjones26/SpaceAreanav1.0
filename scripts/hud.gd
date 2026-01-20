extends CanvasLayer

@onready var score_label = $ScoreLabel


func _on_health_updated(health):
	$Health.text = str(health) + "%"


func _ready():
	# Connect to the global signal
	GameManager.score_changed.connect(_on_score_updated)
	# Set initial score
	score_label.text = "Eliminations: " + str(GameManager.score)


func _on_score_updated(new_score):
	score_label.text = "Eliminations: " + str(new_score)
