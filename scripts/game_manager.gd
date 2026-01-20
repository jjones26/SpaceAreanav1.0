extends Node


signal score_changed(new_score)
var score: int = 0

func add_score(amount: int):
	score += amount
	score_changed.emit(score)

func reset_score():
	score = 0
	score_changed.emit(score)
