extends Node
# Process is as follows:
# Deal and play are counter-clockwise; the cards are shuffled by 
# the player who is in the left . 
# Based on these four cards, players bid for the right to choose 
# trump. Each bid is a number, and the highest bidder undertakes 
# that their side will win in tricks at least the number of points bid. The player to dealer's right speaks first, and must bid at least 14.[1] Subsequent players, in counter-clockwise order, may either bid higher or pass. The auction continues once until the player passes and the bid moves on to the next player.
# The highest bidder chooses a trump suit on the basis of their four 
# cards, and places a card of this suit face down. 
# LOWEST BID: 14
# MAX BID: 28
# The card is not shown to the other players, who therefore 
# will not know at  first what suit is trump: it remains face 
# down in front of the bidder until at some point during the play someone 
# calls for the trump suit to be exposed.
# The dealer then completes the deal, giving four more cards to 
# each player, so that everyone has eight.
signal bet_or_pass(which)
var max_bid = 0
var current_bid = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	print('Please enter a bid:')
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_bet_pressed():
	 
	if current_bid >= 24:
		print('Bid is too high!')
		$Bet.disabled = true

	else:
		current_bid = int($Label.text)
		print('Current bid is set to: ', current_bid)
		print('Bid is set to: ', max_bid)
		$Pass.disabled = true
		$Bet.disabled = true
		emit_signal("bet_or_pass",current_bid)


func _on_pass_pressed():
	print('Bid passed')
	if $Pass.button_pressed == true :
		$Bet.disabled = true
		$Pass.disabled = true
		emit_signal("bet_or_pass",0)

func _on_h_slider_value_changed(value):
	$Label.text = str(value)
	pass # Replace with function body.
