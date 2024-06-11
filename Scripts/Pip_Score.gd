extends Node2D

@onready var Director = $"/root/Director"
var testarray : Array
var team_score = 0
var current_bet = 0
var lose : bool
var lerp_goal : float 
var counter  = 0.0
var change = 0.0
var lerp_factor = 0.08

@onready var label = $"Round Message"
# Called when the node enters the scene tree for the first time.
func _ready():
	team_score = float(Director.team_points)
	current_bet = float(Director.current_bet)
	lose = false if team_score >= current_bet else true
	lerp_goal = team_score if lose else current_bet
	label.text = "Match score:\n%s/%s" %[round(counter), current_bet]
	await get_tree().create_timer(1,false).timeout
	$Timer.start()
	print('ready')
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func time_loop():
	counter = lerp(counter, lerp_goal,lerp_factor)


	if counter > team_score -0.45:
		print("Last BENCHMARK")
		counter = team_score
		$Timer.paused = true
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.pitch_scale += 0.02
		$AudioStreamPlayer.volume_db += 0.002
		label.text = "Match score:\n%s/%s" %[round(counter), current_bet]
		await get_tree().create_timer(.5,false).timeout
		if lose:
			$AudioStreamPlayer.stream = load("res://Assets/SFX & Music/scifi-delete-sound-2-program-mobile-computer-SBA-300463331.wav")
			label.modulate = Color(0.68999999761581, 0.1104000210762, 0.1104000210762)
		else:
			$AudioStreamPlayer.stream = load("res://Assets/SFX & Music/magical-video-game-note-hint-4-SBA-300420782.wav")
		$AudioStreamPlayer.pitch_scale = 1
		$AudioStreamPlayer.volume_db += 0
		$AudioStreamPlayer.play()
		await get_tree().create_timer(2,false).timeout
		queue_free()
		return

	elif counter > lerp_goal -0.4 and team_score >= lerp_goal:
		print("FIRST BENCHMARK")
		counter = current_bet
		#lerp_factor = .10
	if int(counter) > change:
		if counter < current_bet:
			lerp_factor *= .97
		else:
			lerp_factor *= 1.07
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.pitch_scale += 0.02
		$AudioStreamPlayer.volume_db += 0.002
		change = counter
		label.text = "Match score:\n%s/%s" %[round(counter), current_bet]

	if counter == lerp_goal:
		print("SECOND BENCHMARK")
		$Timer.paused = true
		#$AudioStreamPlayer.stream = load("res://Assets/SFX & Music/magical-video-game-note-hint-4-SBA-300420782.wav")
		label.modulate = Color(0.28826001286507, 0.87000000476837, 0.27840000391006)
		$AudioStreamPlayer.play()
		await get_tree().create_timer(1,false).timeout
		$AudioStreamPlayer.stream = load("res://Assets/SFX & Music/simple-beep-notification-alert-5-SBA-300463354.wav")
		$Timer.paused = false
		lerp_goal = team_score
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
