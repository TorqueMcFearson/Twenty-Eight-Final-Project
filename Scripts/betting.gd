extends Control

signal bet_or_pass(which)
var current_bid = 0
var min_bid
var difficulty = 0
var redeal := false
@onready var Director = $"/root/Director"
@onready var bet_based_labels = [$"Bet Please/Amount/Win",$"Bet Please/Amount/Lose",$"Win Label",$"Lose Label"]

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	if not Global.variant_rules.bet_based_pips:
		for each in bet_based_labels:
			each.visible = false
	min_bid = current_bid+1
	if Global.variant_rules.partner_bid and Director.current_better == Director.get_node("Player3"):
		print("same team, clamping to 20 min bet.")
		min_bid= clamp(min_bid,20,99)
		$Redeal.text = "Patner Bid: If you partner was the last to bid, you must bid a minimum of 20."
		$Redeal.visible = true
	if current_bid > 13:
		if Director.current_better == Director.get_node("Player3"):
			$"Current Bet/Amount".add_theme_color_override("font_color",Color(1, 0.48235294222832, 0))
			$"Current Bet/Amount".add_theme_color_override("font_outline_color",Color(1, 0.48235294222832, 0))
			$"Current Bet/Amount".text = str("Teammate Bet: ", current_bid)
		else:
			$"Current Bet/Amount".add_theme_color_override("font_color",Color(0, 0.59999990463257, 1))
			$"Current Bet/Amount".add_theme_color_override("font_outline_color",Color(0, 0.59999990463257, 1))
			$"Current Bet/Amount".text = str("Opponent Bet: ", current_bid)
		$HSlider.min_value = min_bid
		$HSlider.tick_count = 27 - min_bid

	else:
		if redeal and Global.variant_rules.redeal:
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
	$"Bet Please/Amount".modulate = Color.from_hsv(0.31-adjust, 1, 1-adjust*.25)
	if value < 20 :
		if difficulty != 14:
			$"Bet Please/Amount/Difficult".text = "Easy"
			$"Bet Please/Amount/Win".text = "1 pip"
			$"Bet Please/Amount/Lose".text = "-2 pips"
			difficulty = 14
	elif value < 25:
		if difficulty != 20:
			$"Bet Please/Amount/Difficult".text = "Fair"
			$"Bet Please/Amount/Win".text = "2 pips"
			$"Bet Please/Amount/Lose".text = "-3 pips"
			difficulty = 20
	elif value < 29:
		if difficulty != 25:
			$"Bet Please/Amount/Difficult".text = "Hard"
			$"Bet Please/Amount/Win".text = "3 pips"
			$"Bet Please/Amount/Lose".text = "-4 pips"
			difficulty = 25
	#elif value == 28:
		#if difficulty != 28:
			#$"Bet Please/Amount/Difficult".text = "Really!?!?"
			#$"Bet Please/Amount/Win".text = "3 pips"
			#$"Bet Please/Amount/Lose".text = "-4 pips"
			#difficulty = 28
	
	pass # Replace with function body.
