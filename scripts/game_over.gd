extends Control


@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel


func _ready() -> void:
	score_label.text = "Final Score: " + str(GameManager.score)
	high_score_label.text = "High Score: " + str(GameManager.high_score)


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")



func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")




func _on_quit_button_pressed() -> void:
	get_tree().quit()
