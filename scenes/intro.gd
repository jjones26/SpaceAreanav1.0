extends Node3D

@onready var intro_anim = $AnimationPlayer
@onready var intro_cam = $IntroCamera3D
@onready var player_cam = $Player/Camera3D # Path to your player's camera

func _ready():
	# 1. Start the audio/animation immediately
	intro_anim.play("new_animation")
	# 2. Make the intro camera active
	intro_cam.make_current()
	
	# 3. Freeze the game world
	get_tree().paused = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "new_animation":
		# 4. Switch to player's perspective
		player_cam.make_current()
		
		# 5. Unpause the game so player can move
		get_tree().paused = false
		
		# 6. Cleanup (Optional: remove intro camera to save memory)
		intro_cam.queue_free()
