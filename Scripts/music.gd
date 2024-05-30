extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	volume_db = -60
	play()
	get_tree().create_tween().tween_property(self,"volume_db",-18.0,6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	#stream_paused = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_finished():
	play()
	pass # Replace with function body.


