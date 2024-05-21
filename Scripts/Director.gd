extends Node2D

## Game Start Initialization
## NOTE:Database.gd & Music.gd is AutoLoaded into game, so it's in ALL scenes.
## So, music is always active and database is always accessible (without a node).

const MAX_HANDSIZE = 8 # How many cards players can hold.
var drawpile = range(32) # Drawpile is a stack of Integer IDs 0-31 (32 cards)
var discardpile = [] # Empty array. IDs are shuffled back into drawpile.
@onready var dealerpool = [$Player1,$Player2,$Player3,$Player4] #Order of players clockwise
@onready var handpool = [$Player1/Hand, $Player2/Hand, $Player3/Hand, $Player4/Hand]

## Tween globals
var fade_goal = Color(1,1,1,0) # Used for tween and lerp fading.
var fade_rate = .01 # Used for tween and lerp fading.

# Bid round and Play round data
@onready var current_better = $Player1 # Who bet they could win.
var current_bet = 14 # How many tricks they bet they could win.
var round = 0 # Typical round counter for bidding and play stage.
var pass_count = 0 # Typical round counter for bidding and play stage.
var trump_suit : String # What suit the bid-winning player picked.
var trump_revealed : bool # Trump revealed to field true/false
	

# Called when the node enters the scene tree for the first time.
func _ready(): 
	print(drawpile)
	# NOTE: Some elements are disabled/non-visible so I can see them in editor, but not at gamestart.
	$"Black Fade".visible = true # Rectangle $"Black Fade" covers the screen, it's used to fade in and out.
	$Discard_Deck.visible = false # Hides Discard deck until cards are in it.
	$DrawDeck/Amount.text = str(drawpile.size()) #Changes Deck Label to display amount in it.
	$Discard_Deck/Amount.text = '' # Discard Deck starts empty.
	$Shuffle.disabled = true # Shuffle starts disabled because drawpile full
	$Discard_Button.disabled = true # Discard pile starts disabled, No cards in hands.
	$Player1.human = true
	drawpile.shuffle() #Shuffles the array of 31 IDs in drawpile.
	## Debug tool: Just prints to console the draw cirds in order ##
	var cardlist = [] 
	for each in drawpile: 
		var data = Database.cards.get(each)
		cardlist.append(data.face + " of " + data.suit)
	for each in cardlist:
		print(each)
	print("^Drawpile in reverse order^")
	## ------------------Round Calling Starts-------------------------- ## 
	#return     #<---- uncomment 'return' to start main without auto-director.
	await get_tree().create_timer(2).timeout # Typical pause. For 1 sec.
	await _on_deal_all_pressed()					 # 4 cards delt to each player.
	await get_tree().create_timer(3.5).timeout
	get_tree().call_group("Players", "ready_bid") # AI determines it's hand value.
	await betting_round() 					# Calls and waits for the Betting round.
	await trump_round()						# Calls and waits the Trump choosing round.

# We don't use cause our director does things in order, by turn, not frame.
func _process(delta): # This runs a fade in when the scene starts. Stops once faded in.
	fade_in(delta) # Call to Fader.
	
func betting_round():
	while true:		# Endless true Loop until there is a winner, then breaks out.
		round +=1
		print ('\n *****Round ',round, '******\n')
		await Call_betting()						# Calls Human betting screen
		await get_tree().create_timer(1).timeout
		get_tree().call_group("Players", "ai_bid")	# Calls each AIs ai_bid() from Player.gd 
	# NOTE: All Player Objects are in a group called "players", see node tab on right panel.
		if pass_count == 3:							# If 3 pass in a row, break loop.
			break									# Last bid and bidder locked in.
	print("Winner: ", current_better.name, " Bet: ", current_bet)
	# Once loop breaks, this function completes and _ready() continues from await.
	
func trump_round():
	if current_better.human: 				# If human won, will call trump pick window.
		print("THIS WOULD GO TO TRUMP PICK Window.") # Still on my TODO list
	else:									# If AI won, AI picks a trump card.
		trump_suit = current_better.pick_trump() # Calls object's pick_trump function from player.gd
	var tween= get_tree().create_tween() # Slides trump card in. TODO:(AI:Face down, Human:Face up.)
	tween.tween_property($"UI/Trump Card/Trump Sprite",'position',Vector2(0,0),.75).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	_on_deal_all_pressed()
	
func trump_reveal(): # TODO trump face_up if player wins or revealed during play.
	var assemble = str("res://Assets/Cards/PNG/Cards/",trump_suit,"_trump.png")
	$"UI/Trump Card/Trump Sprite".texture = load(assemble)
	pass
	
func second_deal():
	_on_deal_all_pressed()
	
func Call_betting(): # Human betting window called.
	$Player1/Hand.z_index = 5 # Players moved to front of viewport. (5 is random high number)
	var betscene = load("res://betting_ui.tscn").instantiate() # Betting window readied.
	betscene.current_bid = current_bet						# Scene is informed of current bet
	$"Black Fade".modulate = Color(1, 1, 1, 0.50)			# Fade the table behind to 50% black
	add_child(betscene)										# Add the window to the root of scene.
	var bet = await get_node("BettingUI").bet_or_pass		# Pause until signal returns bet or pass.
	if bet: 												# bet returns value (true)
		pass_count = 0										# bets break the pass streak.
		current_bet = bet									# store players returned bet
		current_better = $Player1							# store player object as last bidder
		print('Player Bet: ',bet)
	else:													# Pass returns 0 (false)
		pass_count += 1										# incremeant pass streak.
		print('Player Passed! Count:', pass_count)
	$Player1/Hand.z_index = 0								# Return cards to normal layer.
	betscene.queue_free()									# Kill the betting window.
	$"Black Fade".modulate = Color(1, 1, 1, 0)				# Remove 50% black fade.


## THE EVER IMPORTANT DRAW CARD FUNCTION ##
func draw_card(hand):	
	if not drawpile.size():					# If drawpile array is empty
		print('Draw pile empty, dumbass')
		return 0							# False value for error, stop draws.
	var face_show = true if hand.get_parent().human else false #if human, card faceup
	var children = hand.get_child_count()	# How many cards already in hand.
	# Requests card object from constructor script, configured using an ID from top of drawpile.
	if children == MAX_HANDSIZE:			# Skip hand if hand is full.
		('Hands full, greedy pig boy!')
		return 1							# return true because we skip, not stop.
	var new_card = $CardConstructor.newcard(drawpile.pop_back(),face_show) 
	new_card.slot = Vector2(children*40,0) # Position stored relative to amount of cards in hand.
	hand.add_child(new_card)				# Add card object to scene under requesting hand.
	new_card.global_position = $DrawDeck.global_position - Vector2(-64,-64) # position center of draw deck
	new_card.grow_and_go(hand) # Tween animations of scale-up and move-to stored position in hand.
	$Card_Fwip.play(.11)		# Card SFX
	$DrawDeck/Amount.text = str(drawpile.size()) # Refresh the amount label on drawdeck.
	if drawpile.size() == 0:					# If that was last card, make drawdeck disappear.
		butt_off()
		$DrawDeck.visible = false
	return 1									# True value for success


func _on_deal_all_pressed(): ## NOTE: Used by Director and Deal all button. Deals 4 cards to ALL.
	butt_off()						# Disabled buttons til end of function.
	var time=0.40					# Time between each card.
	$Card_Fwip.pitch_scale = .69	# Card SFX
	for n in MAX_HANDSIZE/2:		# For 4 cards
		for hand in handpool:		# For each hand
			if not draw_card(hand):	# Run Draw_card(), if return 0, empty draw deck.
				butt_check()
				return
			await get_tree().create_timer(time).timeout # wait 'time' before next card
			$Card_Fwip.pitch_scale += .01 # Raise SFX pitch a little each card
			time = time+.005-(time*time) # Decrease time between cards for speed up
	$Card_Fwip.pitch_scale = .69		# Reset SFX pitch when done.
	butt_check()					# Reset buttons when done.

func _on_discard_button_pressed(): # Discards all hands to discard pile. 
	## NOTE: Tied to a button, no  use in real game as cards would go to trick piles, not discard.
	## So I need to retool this into 4 player-trick decks.. or 2 team-trick decks
	butt_off()						# Disabled buttons til end of function.
	var time=0.40					# Time between each card.
	$Card_Fwip.pitch_scale = .69	# Card SFX
	$Discard_Deck.visible = true	# Show  sprite
	for hand in handpool:			# For each hand.
		for card in hand.get_children():	# For each card in each hand
			var id = card.get('id')			# Get their ID.
			discardpile.append(id)			# Dump ID into discard array.
			card.go_and_die()				# tween from position to discard_deck.
			await get_tree().create_timer(time).timeout #wait 'time' before next card 
			$Discard_Deck/Amount.text = str(discardpile.size()) # Update discarddeck label
			$Card_Fwip.play()				# SFX
			$Card_Fwip.pitch_scale += .01	# Raise SFX pitch a little each card
			time = time+.005-(time*time)	# Decrease time between cards for speed up
	$Card_Fwip.pitch_scale = .69			# Reset SFX pitch when done.
	butt_check()					# Reset buttons when done.
	
## Trigger for $flip_cards button
func _on_flip_cards_pressed(): # Useless button for flipping cards for fun.
	$Card_Fwip.play(.07)		# SFX
	var cards = $Player1/Hand.get_children()	# Get cards in Player1 hand.
	for card in cards:			# For each card 
		card.face_toggle()		# run their face_toggle() inside their Player.gd

## \/ Screen Buttons & State handlers \/ ##
## NOTE: BUTTONS are for debug, won't be in final game. Make visibile from scene tree for use

# Button State handlers ##
func butt_check():
	if not drawpile.size(): 	# Leave draw buttons off if drawpile is empty
		reset_on()
	else:						# Else: All Buttons back on.
		butt_on()
func butt_on():
	$Shuffle.disabled = false
	$Discard_Button.disabled = false
	$Deal_ALL.disabled = false
	$Deal_One_Card.disabled = false
func butt_off():
	$Shuffle.disabled = true
	$Discard_Button.disabled = true
	$Deal_ALL.disabled = true
	$Deal_One_Card.disabled = true
func reset_on():
	$Discard_Button.disabled = false
	$Shuffle.disabled = false
func reset_off():
	$Discard_Button.disabled = true
	$Shuffle.disabled = true

func _on_shuffle_pressed(): # Move IDs from Discardpile to Drawpile
	drawpile.append_array(discardpile)	# Copy IDs to drawpile.
	discardpile = []					# Delete IDs from discardpile
	$Card_Shuffle.play()		# SFX
	drawpile.shuffle()			# Shuffle IDs in drawpile
	deck_refresh()				# Visually referesh onscreen decks
	
func deck_refresh():	# Update labels and deck sprites. DEBUG TOOL
	butt_on()
	var drawpile_size = drawpile.size()		
	var discardpile_size = discardpile.size()
	$Discard_Deck/Amount.text = str(discardpile_size)
	$DrawDeck/Amount.text = str(drawpile_size)
	$DrawDeck.visible = drawpile_size		#if 0 false, else true (truthy value)
	$Discard_Deck.visible = discardpile_size
	$Shuffle.disabled = true

func fade_in(delta): # Simple screen fading using lerp on "Black Fade" node.
	var fade_mod = $"Black Fade".get_modulate() # modulate lets us set opacity.
	# NOTE: Lerp just splits a differce. From value to value by percent (0,100,.5) = 50
	# every call uses its previous output, so there's a smooth easing out.
	# (0,100,.5) = 50, (50,100,.5)= 75,87.5,93.7,96.8,....
	$"Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.03			# Accelerate as it goes too.
	if fade_mod.a <0.1:		# Since we never reach goal, set a threshhold to reach.
		$"Black Fade".set_modulate(fade_goal)	# And then just assign goal.
		print("DONE")
		set_process(false)	# Stop _proccess, which is calling this function every frame.

func fade_out(delta): # Same as fade_in.. actually might just merge the two..
	# the function that calls will change the fade goal to NOT TRANSPARENT.
	var fade_mod = $"Black Fade".get_modulate()
	$"Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.03
	if fade_mod.a <0.1:
		print("DONE")
		set_process(false)


func playcard(card): # Click cards are moved to their assigned playslot
	var player = card.get_node("../..") 		# "../.." means parent of my parent.
	var playslot = player.get_node("Playslot")  # store playslot object
	if playslot.get_child_count():				# If playslot has card, cancel function.
		return 
	var hand = card.get_parent()				# store hand object
	if player.human: 							# checks if Player is human.
		var slot = Vector2(0,0)					# stores a base position.
		card.slot = slot						# Updates the card's variable for upcoming tween.
		card.reparent(playslot)					# Moves card object from hand to playslot
		card.go()								# Tweens to playslot's base position (0,0)
		card.inplay = true						# Set flag in objects variables.
		card.get_node("shadow").visible = false # Removes shadow (laying flat on table)
		$Card_Fwip.play()						# SFX
		for each in hand.get_children():		# For each card still in hand
			each.slot = slot					# Update card with new spot in hand.
			each.go()							# Tween them there.
			slot += Vector2(40,0)				# Increase for next card.
		get_tree().create_tween().tween_property($"Play Card",'modulate', Color(1,1,1,1),.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO).set_delay(.25)
		# ^This fades in a Play Card button I'm working on.. to lock in your decision. ##
	else:		# If AI's card, prevents you from playing it.
		print('not yours')

func take_card(card): # An inversion of playcard() move playslot card back to hand.
	get_tree().create_tween().tween_property($"Play Card",'modulate', Color(1,1,1,0),.2).set_ease(Tween.EASE_IN)
	var to_hand = card.get_node("../../Hand")
	var children = to_hand.get_child_count()
	if children > 7:
		print('Hand is full, dumbass')
		return 0
	var x_offset = children
	card.reparent(to_hand,true)
	card.slot = Vector2(0,0) + Vector2(children*40,0)
	#card.global_position = card.slot
	card.go()
	$Card_Fwip.play(.11)
	card.inplay = false
	return 1
	
func _on_deal_one_card_pressed(): # Deal 1 card button. _on_deal_all_pressed()
	butt_off()
	if not draw_card($Player1/Hand):
				butt_check()
				return
	butt_check()
	pass # Replace with function body

func _on_play_card_pressed(): # Play card in play slot.. TODO:
	var card = $Player1/Playslot.get_child(0)
	if card:
		print(card.face,' of ',card.suit, " Card Played") # Currently just prints card.
	pass # Replace with function body.


