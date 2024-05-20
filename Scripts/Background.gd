extends Sprite2D

var hue_value = 0.90
var light_value = .82
var light_value_dir = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	modulate = Color.from_hsv(hue_value, 0.18, light_value, 0.705)
	if hue_value >= 1:
		hue_value = .01
	else:
		hue_value += .1  * delta
		
	if light_value >= .60:
		light_value_dir=-1
	elif light_value <= .80:
		light_value_dir=1
	light_value += .1 * light_value_dir * delta
		

