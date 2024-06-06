extends Node2D

@onready var Director = $"/root/Director"
var points = 0
var lerp_goal : float
var counter  = 0.0
var change = 0.0
var lerp_factor = 0.12

@onready var label = $"Round Message"
# Called when the node enters the scene tree for the first time.
func _ready():
	var player_pos = Director.trick_winner[0].name as String
	position = get_node(player_pos).position
	lerp_goal = points
	if points == 0:
		$AudioStreamPlayer.pitch_scale = 0.66
		$AudioStreamPlayer.stream = load("res://Assets/SFX & Music/button-stutter-SBA-300098808.wav")
		label.add_theme_color_override("font_color",Color("gray"))
		label.text = "Points\n" + str(round(counter))
		$AudioStreamPlayer.play()
		await get_tree().create_tween().tween_property(self,"modulate",Color(1,1,1,0),.75).set_delay(1.5).finished
		queue_free()
		return
	#await get_tree().create_timer(.75).timeout
	#$"Round Message".position = Vector2(842,284)
	label.text = "Points\n+" + str(round(counter))
	$Timer.start()
	print('ready')
	
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func time_loop():
	print(counter," vs ",change)
	counter = lerp(counter, lerp_goal,lerp_factor)


	if counter > lerp_goal -0.45:
		print("Last BENCHMARK")
		$Timer.paused = true
		$AudioStreamPlayer.pitch_scale += 0.02
		$AudioStreamPlayer.volume_db += 0.002
		#$AudioStreamPlayer.play()
		label.text = "Points\n+" + str(round(counter))
		if points == 0:
			$AudioStreamPlayer.pitch_scale = 0.66
			$AudioStreamPlayer.stream = load("res://Assets/SFX & Music/button-stutter-SBA-300098808.wav")
		#$AudioStreamPlayer.pitch_scale = 1
		$AudioStreamPlayer.volume_db += 0
		$AudioStreamPlayer.play()
		await get_tree().create_tween().tween_property(self,"modulate",Color(1,1,1,0),.75).set_delay(.25).finished
		queue_free()
		return
		
	if int(counter) > change:
		lerp_factor *= 1.02
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.pitch_scale += 0.02
		$AudioStreamPlayer.volume_db += 0.002
		change = counter
		label.text = "Points\n+" + str(round(counter))

	pass
#func round_message(message : String,duration):	# Template for making a message fade in center of screen.
#func pip_scoring():
	#var label = $"Round Message"
	#label.text = message
	#await get_tree().create_tween()\
			#.tween_property(label,"modulate",Color(1, 1, 1,1),.35)\
			#.set_ease(Tween.EASE_IN_OUT).finished	# No delay for fade in.
			#
	#await get_tree().create_tween()\
			#.tween_property(label,"modulate",Color(1, 1, 1,0),.35)\
			#.set_ease(Tween.EASE_IN_OUT)\
			#.set_delay(duration).finished			# Duration delay before fades out.
