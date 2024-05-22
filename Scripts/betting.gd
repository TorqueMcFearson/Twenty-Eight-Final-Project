extends Node
# Process is as follows:
# Deal and play are counter-clockwise; the cards are shuffled by 
# the player who is in the left . 
# Based on these four cards, players bid for the right to choose 
# trump. Each bid is a number, and the highest bidder undertakes 
# that their side will win in tricks at least the number of points bid. The player to dealer's right speaks first, and must bid at least 14.[1] Subsequent players, in counter-clockwise order, may either bid higher or pass. The auction continues once until the player passes and the bid moves on to the next player.
# The highest bidder chooses a trump suit on the basis of their four 
# cards, and places a card of this suit face down. 
# LOWEST BID: 15
# MAX BID: 28
# The card is not shown to the other players, who therefore 
# will not know at  first what suit is trump: it remains face 
# down in front of the bidder until at some point during the play someone 
# calls for the trump suit to be exposed.
# The dealer then completes the deal, giving four more cards to 
# each player, so that everyone has eight.
signal bet_or_pass(which)
var current_bid = 0
var difficulty = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if current_bid:
		$"Current Bet/Amount".text = str("Current Bet: ", current_bid)
		$HSlider.min_value = current_bid+1
		$HSlider.tick_count = 28 - current_bid
	else:
		$Pass.visible = false
		$Bet.position.x += 71
		$HSlider.min_value = 14
		$"Current Bet".visible = false
		$"Bet Please/Label".text = "Starting Bet:"
	_on_h_slider_value_changed($HSlider.value)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bet_pressed():
	$Pass.disabled = true
	$Bet.disabled = true
	current_bid = $HSlider.value
	emit_signal("bet_or_pass",current_bid)


func _on_pass_pressed():
		$Bet.disabled = true
		$Pass.disabled = true
		emit_signal("bet_or_pass",0)


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
	elif value > 23:
		if difficulty != 23:
			$"Bet Please/Amount/Difficult".text = "Hard"
			#$"Bet Please/Amount".modulate = Color(0.81, 0, 0)
			difficulty = 23
	
	pass # Replace with function body.
