extends Control

signal bet_or_pass(which)
var current_bid = 0
var difficulty = 0
var redeal := false
@onready var Director = $"/root/Director"


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	if current_bid > 13:
		if Director.current_better == Director.get_node("Player3"):
			$"Current Bet/Amount".add_theme_color_override("font_color",Color(1, 0.48235294222832, 0))
			$"Current Bet/Amount".add_theme_color_override("font_outline_color",Color(1, 0.48235294222832, 0))
			$"Current Bet/Amount".text = str("Teammate Bet: ", current_bid)
		else:
			$"Current Bet/Amount".add_theme_color_override("font_color",Color(0, 0.59999990463257, 1))
			$"Current Bet/Amount".add_theme_color_override("font_outline_color",Color(0, 0.59999990463257, 1))
			$"Current Bet/Amount".text = str("Opponent Bet: ", current_bid)
		$HSlider.min_value = current_bid+1
		$HSlider.tick_count = 28 - current_bid
	elif redeal:
		$Pass.text = "Redeal"
		$Redeal.visible = true
	else:
		$Pass.visible = false
		$Bet.position.x += 71
		$HSlider.min_value = 14
		$"Current Bet".visible = false
		$"Bet Please/Label".text = "Starting Bet:"
	_on_h_slider_value_changed($HSlider.value)
	fade_in()
	pass

func fade_in():
	get_tree().create_tween()\
			.tween_property(self,"modulate",Color(1,1,1,1),1)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func fade_out():
		get_tree().create_tween()\
			.tween_property(self,"modulate",Color(1,1,1,0),.45)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bet_pressed():
	$Pass.disabled = true
	$Bet.disabled = true
	current_bid = $HSlider.value
	$"/root/Director/SFX/Card_Ding".pitch_scale = current_bid*.02+.41
	$"/root/Director/SFX/Card_Ding".play()
	$"/root/Director/SFX/Card_Whiff".pitch_scale = .65
	emit_signal("bet_or_pass",current_bid)
	fade_out()


func _on_pass_pressed():
	if redeal:
		$"/root/Director/Player1".redeal()
		$Pass.disabled = true
		$Redeal.visible = false
	else:
		$Bet.disabled = true
		$Pass.disabled = true
		$"/root/Director/SFX/Card_Whiff".pitch_scale += 0.03
		$"/root/Director/SFX/Card_Whiff".play()
		emit_signal("bet_or_pass",0)
		fade_out()


func _on_h_slider_value_changed(value):
	$"Bet Please/Amount".text = str(value)
	var adjust = (value-14)*.025
	$"Bet Please/Amount".modulate = Color.from_hsv(0.37-adjust, 1, 1-adjust*.75)
	
	if value < 19 :
		if difficulty != 14:
			$"Bet Please/Amount/Difficult".text = "Easy"
			#$"Bet Please/Amount".modulate = Color(0.033, 1, 0)
			difficulty = 14
	elif value < 23:
		if difficulty != 19:
			$"Bet Please/Amount/Difficult".text = "Fair"
			#$"Bet Please/Amount".modulate = Color(0.9, 0.825, 0)
			difficulty = 19
	elif value < 27:
		if difficulty != 23:
			$"Bet Please/Amount/Difficult".text = "Hard"
			#$"Bet Please/Amount".modulate = Color(0.81, 0, 0)
			difficulty = 23
	elif value > 27:
		if difficulty != 28:
			$"Bet Please/Amount/Difficult".text = "Really!?!?"
			#$"Bet Please/Amount".modulate = Color(0.81, 0, 0)
			difficulty = 28
	
	pass # Replace with function body.
