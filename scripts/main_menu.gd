extends Control


@onready var credits_popup: ColorRect = $CreditsPopup
@onready var high_score_label: Label = $HighScorePopup/HighScoreLabel
@onready var high_score_popup: ColorRect = $HighScorePopup



func _ready() -> void:
	high_score_label.text = "High Score: " + str(GameManager.high_score)
	credits_popup.visible = false
	high_score_popup.visible = false


func _on_start_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_credits_button_pressed() -> void:
	credits_popup.visible = true


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_close_button_pressed() -> void:
	credits_popup.visible = false


func _on_high_score_button_pressed() -> void:
	high_score_popup.visible = true


func _on_high_score_close_button_pressed() -> void:
	high_score_popup.visible = false
