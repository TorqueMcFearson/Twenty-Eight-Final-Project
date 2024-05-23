extends Control

#signal bet_or_pass(which)
#var current_bid = 0
#var difficulty = 0
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	##print($"Bet Please/HBoxContainer".is_visible_in_tree())
	##for each in $"Bet Please/HBoxContainer".get_children():
		##print(each.is_visible_in_tree())
	##modulate.a = 0
	##if current_bid:
		##$"Current Bet/Amount".text = str("Current Bet: ", current_bid)
		##$HSlider.min_value = current_bid+1
		##$HSlider.tick_count = 28 - current_bid
	##else:
		##$Pass.visible = false
		##$Bet.position.x += 71
		##$HSlider.min_value = 14
		##$"Current Bet".visible = false
		##$"Bet Please/Label".text = "Starting Bet:"
	##_on_h_slider_value_changed($HSlider.value)
	##fade_in()
	#pass
#
#func fade_in():
	#get_tree().create_tween()\
			#.tween_property(self,"modulate",Color(1,1,1,1),1)\
			#.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
#
#func fade_out():
		#get_tree().create_tween()\
			#.tween_property(self,"modulate",Color(1,1,1,0),.45)\
			#.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
#
#
#func _on_bet_pressed():
	#$Pass.disabled = true
	#$Bet.disabled = true
	#current_bid = $HSlider.value
	#emit_signal("bet_or_pass",current_bid)
	#fade_out()
#
#
#func _on_pass_pressed():
		#$Bet.disabled = true
		#$Pass.disabled = true
		#emit_signal("bet_or_pass",0)
		#fade_out()
#
#
#func _on_h_slider_value_changed(value):
	#$"Bet Please/Amount".text = str(value)
	#var adjust = (value-14)*.025
	#$"Bet Please/Amount".modulate = Color.from_hsv(0.37-adjust, 1, 1-adjust*.75)
	#
	#if value < 19 :
		#if difficulty != 14:
			#$"Bet Please/Amount/Difficult".text = "Easy"
			##$"Bet Please/Amount".modulate = Color(0.033, 1, 0)
			#difficulty = 14
	#elif value < 23:
		#if difficulty != 19:
			#$"Bet Please/Amount/Difficult".text = "Fair"
			##$"Bet Please/Amount".modulate = Color(0.9, 0.825, 0)
			#difficulty = 19
	#elif value < 27:
		#if difficulty != 23:
			#$"Bet Please/Amount/Difficult".text = "Hard"
			##$"Bet Please/Amount".modulate = Color(0.81, 0, 0)
			#difficulty = 23
	#elif value > 27:
		#if difficulty != 28:
			#$"Bet Please/Amount/Difficult".text = "Really!?!?"
			##$"Bet Please/Amount".modulate = Color(0.81, 0, 0)
			#difficulty = 28
	#
	#pass # Replace with function body.


func _on_button_mouse_entered(suit):
	$"Bet Please".get_node(suit).scale = Vector2(.75,.75)
	print(suit)
	pass # Replace with function body.


func _on_button_mouse_exited(suit):
	$"Bet Please".get_node(suit).scale = Vector2(.625,.625)
	pass # Replace with function body.


func _on_pressed(suit):
	print(suit)
	pass # Replace with function body.
