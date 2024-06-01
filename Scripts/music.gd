extends AudioStreamPlayer
var saved_volume = -18

# Called when the node enters the scene tree for the first time.
func _ready():
	volume_db = -60
	play()
	fade_in(6)
	#stream_paused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func fade_in(duration):
	volume_db = -60
	create_tween().tween_property($".","volume_db",saved_volume,duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	play()
	
func fade_out(duration):
	saved_volume = volume_db
	await create_tween().tween_property($".","volume_db",-60,duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).finished
	
func _on_finished():
	play()
	pass # Replace with function body.


