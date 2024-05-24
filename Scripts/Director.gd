extends Node2D

## Game Start Initialization
## NOTE:Global.gd & Music.gd is AutoLoaded into game, so it's in ALL scenes.
## So, music is always active and database is always accessible (without a node).

const MAX_HANDSIZE = 8 # How many cards players can hold.
var drawpile = range(32) # Drawpile is a stack of Integer IDs 0-31 (32 cards)
var discardpile = [] # Empty array. IDs are shuffled back into drawpile.
@onready var dealer = $Player1
@onready var playerpool = [$Player1,$Player2,$Player3,$Player4] # Order of players clockwise
@onready var handpool = [$Player1/Hand, $Player2/Hand, $Player3/Hand, $Player4/Hand]

## Tween globals
var fade_goal = Color(1,1,1,0) # Used for tween and lerp fading.
var fade_rate = .01 # Used for tween and lerp fading.

# The Bid_Stage Data
@onready var current_better = $Player1 		# Who bet they could win. 
var current_bet: int = 0 			  		# How many tricks they bet they could win.
var round: int = 0 							# Typical round counter for bidding and play stage.
var pass_count: int = 0						# Typical pass counter for bidding and play stage.
var trump_revealed := false 					# Trump revealed to field true/false
var trump_suit : String 					# What suit the bid-winning player picked.

# The Trick Data
var highest_rank : int
var trick_suit : String
var trick_winner = ["Null",0]





func timer(x):
	return get_tree().create_timer(x).timeout
	
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
	match_start()
	## Debug tool: Just prints to console the draw cards in order ##
	#var cardlist = [] 
	#for each in drawpile: 
		#var data = Global.cards.get(each)
		#cardlist.append(data.face + " of " + data.suit)
	#for each in cardlist:
		#print(each)
	#print("^Drawpile in reverse order^")


## ------------------Round Calling Starts-------------------------- ## 
func match_start(): 
	#return     #<---- uncomment 'return' to start main without auto-director.
	await timer(1.5) # Typical pause. For 1 sec.
	await round_message("Match Begins!",1.5)
	await _on_deal_all_pressed()					 # 4 cards delt to each player.
	await timer(.5)
	get_tree().call_group("Players", "ready_bid") # AI determines it's hand value.
	await betting_stage() 					# Calls and waits for the Betting round.
	await trump_stage()						# Calls and waits the Trump choosing round.
	#for each in $Player1/Hand.get_children():	#@TEST for trump outline mechanic. 
		#each.trump_check()					# Enable to highlight trumps when player wins
	get_tree().call_group("Players", "ready_bid")
	await game_stage()
	


func _process(delta): # This runs a fade in when the scene starts. Stops once faded in.
	fade_in(delta) # Call to Fader.


func betting_stage():
	while true:		# Endless true Loop until there is a winner, then breaks out.
		round +=1
		print ('\n *****Round ',round, '******\n')
		await call_bet_window()					# Calls Human betting screen
		await get_tree().create_timer(1).timeout
		#get_tree().call_group("Players", "ai_bid")  # Calls each AIs ai_bid() from Player.gd 
		for player in playerpool:
			await player.ai_bid()
		# NOTE: All Player Objects are in a group called "players", see node tab on right panel.
		if pass_count == 3:							# If 3 pass in a row, break loop.
			break									# Last bid and bidder locked in.
	print("Winner: ", current_better.name, " Bet: ", current_bet)
	dealer = current_better
	
	# Once loop breaks, this function completes and _ready() continues from await.


func trump_stage():
	trump_suit = await current_better.pick_trump() 			# Calls for the bid winner to process trump choice (Player.gd)
	if current_better.human:
		var assemble = str("res://Assets/Cards/PNG/Cards/",trump_suit,"_trump.png")
		$"UI/Trump Card/Trump Sprite".texture = load(assemble)
	var tween= get_tree().create_tween() 				# Slides trump card in. TODO:(AI:Face down, Human:Face up.)
	tween.tween_property($"UI/Trump Card/Trump Sprite",'position',Vector2(0,0),.75)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SPRING)
	_on_deal_all_pressed()
	await get_tree().create_timer(3).timeout


func trump_reveal(): # TODO trump face_up if player wins or revealed during play.
	var assemble = str("res://Assets/Cards/PNG/Cards/",trump_suit,"_trump.png")
	$"UI/Trump Card/Trump Sprite".texture = load(assemble)
	trump_revealed = true
	pass


func second_deal():
	_on_deal_all_pressed()

func game_stage():
	for n in 8:
		for hand in handpool:
			for card in hand.get_children():
				card.enable_card()
		await timer(1)
		var i = playerpool.find(dealer) 		# Gets the index of the dealer in player pool. Like 3
		for index in range(i,(i+4)):			# For a 4 count range from the index.. Like [3,4,5,6]
			var player = playerpool[index%4]	# Sets the player by index using mods 4 to wrap around to 0. Like 3,0,1,2
			print('\n',player,"'s turn!")
			await player.play_turn()
			print(player,"'s turn finished!")					# Calls to the player to to play a card.
			await timer(1.5)
		print('*** Trick Complete ***\nStarting scoring.. trick_suit %s, ')
		i = 0
		for playslot in get_tree().get_nodes_in_group('Playslots'):
			var player = playslot.get_parent()
			var card = playslot.get_child(0)
			print(player.name, " plays ", card.face, card.suit, ' worth ', card.rank)
			if card.suit == trick_suit and card.rank >= trick_winner[1]:
				print(player,card.rank," beats ", trick_winner)
				trick_winner = [player,card.rank]
			elif card.suit == trump_suit and trump_revealed:
				print("Trump discovered during score")
				trick_suit = trump_suit
		for playslot in get_tree().get_nodes_in_group('Playslots'):
			print()
			var card = playslot.get_child(0)
			card.slot = (trick_winner[0].get_node("Hand").to_global(Vector2(250,400)))
			card.go_and_die()
			await timer(0.08)
		print("winner",trick_winner)
		round_message(str(trick_winner[0].name, " wins!"),1.5)
		dealer = trick_winner[0]
		await timer(.6)
	
	
	
	

func call_bet_window(): # Human betting window called.
	$Player1/Hand.z_index = 5 									# Players moved to front of viewport. (5 is random high number)
	var bet_scene = load("res://betting_ui.tscn").instantiate() # Betting window readied.
	$"Black Fade".modulate = Color(1, 1, 1, 0.50)			# Fade the table behind to 50% black
	bet_scene.current_bid = current_bet
	$PopUp.add_child(bet_scene)										# Add the window to the root of scene.
	var bet = await get_node("PopUp/BettingUI").bet_or_pass		# Pause until signal returns bet or pass.
	if bet: 												# bet returns value (true)
		pass_count = 0										# bets break the pass streak.
		current_bet = bet									# store players returned bet
		current_better = $Player1							# store player object as last bidder
		print('Player Bet: ',bet)
	else:													# Pass returns 0 (false)
		pass_count += 1										# incremeant pass streak.
		print('Player Passed! Count:', pass_count)
	$Player1/Hand.z_index = 0								# Return cards to normal layer.
	bet_scene.queue_free()									# Kill the betting window.
	$"Black Fade".modulate = Color(1, 1, 1, 0)				# Remove 50% black fade.




func round_message(message,duration):
	var label = $"Round Message"
	label.text = message
	await get_tree().create_tween()\
			.tween_property(label,"modulate",Color(1, 1, 1,1),.35)\
			.set_ease(Tween.EASE_IN_OUT).finished
	await get_tree().create_tween()\
			.tween_property(label,"modulate",Color(1, 1, 1,0),.35)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(duration).finished
	
	
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
	new_card.grow_and_go() # Tween animations of scale-up and move-to stored position in hand.
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
	for n in 4:						# For 4 cards
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
		$"Black Fade".top_level = false


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
 							# checks if Player is human.
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
	await get_tree().create_tween().tween_property($"Play Card",'modulate', Color(1,1,1,1),.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO).set_delay(.25)
		# ^This fades in a Play Card button I'm working on.. to lock in your decision. ##



func take_card(card): # An inversion of playcard() move playslot card back to hand.
	card.get_node("shadow").visible = true
	get_tree().create_tween().tween_property($"Play Card",'modulate', Color(1,1,1,0),.2).set_ease(Tween.EASE_IN)
	var to_hand = card.get_node("../../Hand")
	var children = to_hand.get_child_count()
	if children > 7:
		print('Hand is full, dumbass')
		return 0
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


func _on_play_card_pressed(): # Play card in play slot..
	var card = $Player1/Playslot.get_child(0)
	if card:
		print(card.face,' of ',card.suit, " Card Played") # Currently just prints card.
	$"Play Card".disabled
	
	pass # Replace with function body.


func _on_texture_button_2_toggled(toggled_on):
	print ('engine timescale: ',Engine.time_scale)
	if toggled_on:
		Engine.time_scale = 2.5

	else:
		Engine.time_scale = 1

	pass # Replace with function body. # Replace with function body.
