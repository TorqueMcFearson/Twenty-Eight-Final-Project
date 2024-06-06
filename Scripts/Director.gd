extends Node2D

## Game Start Initialization
## NOTE:Global.gd & Music.gd is AutoLoaded into game, so it's in ALL scenes.
## So, music is always active and database is always accessible (without a node).

const MAX_HANDSIZE = 8 # How many cards players can hold.
var drawpile = range(32) # Drawpile is a stack of Integer IDs 0-31 (32 cards)
var discardpile = [] # Empty array. IDs are shuffled back into drawpile.
@onready var team1 = ["Player1","Player3"]
@onready var team2 = ["Player2","Player4"]
var dealer_match = 0
@onready var playerpool = [$Player1,$Player2,$Player3,$Player4] # Order of players clockwise
@onready var handpool = [$Player1/Hand, $Player2/Hand, $Player3/Hand, $Player4/Hand]
@onready var dealer = $Player1

## Tween globals
var fade_goal = Color(1,1,1,0) # Used for tween and lerp fading.
var fade_rate = .01 # Used for tween and lerp fading.

# The Bet Data
@onready var current_better = $Player1 		# Who bet they could win. 
var current_bet: int = 13 			  		# How many tricks they bet they could win.
var round: int = 0 							# Typical round counter for bidding and play stage.
var pass_count: int = 0						# Typical pass counter for bidding and play stage.
var trump_revealed := false 				# Trump revealed to field true/false
var trump_suit : String 					# What suit the bid-winning player picked.
var betting_team
var team_points = 0
var bet_won : bool
var leading_card = 0
var pip_change = 1
var pair_flag = false

# The Trick Data
var trick_suit : String
var trick_winner = ["Null",0]
signal card_played
signal move_on

# The Match Data
var team1_pips := 0
var team2_pips := 0


func timer(x): # Shortcut for a wait timer because the code below is too long.
	return get_tree().create_timer(x,false).timeout

func _unhandled_input(event):
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_1):
			Engine.time_scale = 2
			_on_texture_button_2_toggled()
		elif Input.is_key_pressed(KEY_2):
			Engine.time_scale = 1
			_on_texture_button_2_toggled()
		elif Input.is_key_pressed(KEY_3):
			Engine.time_scale = 1.5
			_on_texture_button_2_toggled()
		
		
	
	
func _ready():
	print(drawpile)
	# NOTE: Some elements are disabled/non-visible so I can see them in editor, but not at gamestart.
	$"Black Fade".visible = true # Rectangle $"Black Fade" covers the screen, it's used to fade in and out.
	$Discard_Deck.visible = false # Hides Discard deck until cards are in it.
	$DrawDeck/Amount.text = str(drawpile.size()) #Changes Deck Label to display amount in it.
	$Discard_Deck/Amount.text = '' # Discard Deck starts empty.
	if not Global.guides:
		$"UI/Bet Node".visible = false
	$"UI/Bet Node/Bet Label".modulate = 0xffffff00
	$Player1.human = true
	$"Round Message".modulate = 0xffffff00
	print('dealer: ',dealer)
	drawpile.shuffle() #Shuffles the array of 31 IDs in drawpile.
	await timer(.55) # Typical pause. For 1 sec.
	match_settings()
	await move_on
	Global.database_constructor()
	match_start()
	
	## Debug tool: Uncomment to activate ## Just prints to console the draw cards in order ##
	#var cardlist = [] 
	#for each in drawpile: 
		#var data = Global.cards.get(each)
		#cardlist.append(data.face + " of " + data.suit)
	#for each in cardlist:
		#print(each)
	#print("^Drawpile in reverse order^")


func initialize():
	print("\n*`*`*`* INITIALIZING GAME *`*`*`*`*")
	var trump_sprite = $"UI/Trump Card/Trump Sprite"
	var tween= get_tree().create_tween() 				# Slides trump card in. TODO:(AI:Face down, Human:Face up.)
	tween.tween_property(trump_sprite,'position',Vector2(0,-390),.75)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SPRING)
	trump_sprite.texture = load("res://Assets/Cards/PNG/Cards/cardBack_red4.png")
	$"UI/Bet Node/Bet Label".modulate = Color(0, 0, 0, 0)
	current_bet = 13 			  		# How many tricks they bet they could win.
	round= 0 							# Typical round counter for bidding and play stage.
	pass_count= 0						# Typical pass counter for bidding and play stage.
	trump_revealed = false 				# Trump revealed to field true/false
	trump_suit = ""					# What suit the bid-winning player picked.
	betting_team = null
	trick_suit = ""
	trick_winner = ["Null",0]
	dealer_match = (dealer_match+1) % 4
	dealer = playerpool[dealer_match]
	team_points = 0
	leading_card = 0
	pip_change = 1
	current_better = dealer 		# Who bet they could win. 
	drawpile = range(32)
	$SFX/Card_Shuffle.play()		# SFX
	drawpile.shuffle()			# Shuffle IDs in drawpile
	for player in playerpool:
		await player.initialize()
	deck_refresh()				# Visually referesh onscreen decks
	match_start()


## ------------------Round Calling Starts-------------------------- ## 
func match_start(): 
	#return				 #<---- uncomment 'return' to start main without auto-director.

	await timer(.75) # Typical pause. For 1 sec.
	round_message("Match Begins!",1.5)
	await timer(.75)
	await _on_deal_all_pressed()					 # 4 cards delt to each player.
	#return				#<---- uncomment 'return' to start main without auto-director.
	await timer(.5)
	get_tree().call_group("Players", "ready_bid") # AI determines it's hand value.
	await betting_stage() 					# Calls and waits for the Betting round.
	await timer(1.25)
	await trump_stage()
	await timer(.54)						# Calls and waits the Trump choosing round.
	await _on_deal_all_pressed()
	await get_tree().create_timer(.75,false).timeout
	if current_better == $Player1:
		print("trump check cause player 1 is bidder")
		for each in $Player1/Hand.get_children():	#@TEST for trump outline mechanic. 
			each.trump_check()					# Enable to highlight trumps when player wins
	get_tree().call_group("Players", "ready_bid")
	await get_tree().create_timer(.75,false).timeout
	if Global.variant_rules.final_bet and current_bet < 20:
		await final_bet()
	await timer(1)
	await game_stage()
	await pip_stage()

func match_settings():
	var setting_scene = load("res://Match Settings.tscn").instantiate()

	$PopUp.add_child(setting_scene)

func _process(delta): # This runs a fade in when the scene starts. Stops once faded in.
	fade_in(delta) # Call to Fader.


func betting_stage():
	while true:		# Endless true Loop until there is a winner, then breaks out.
		round +=1
		print ('\n *****Round ',round, '******\n')
		await get_tree().create_tween().tween_property($"UI/Bet Node/Bet Label","modulate",Color(1,1,1,1),.75).finished
		var i = playerpool.find(dealer) 		# Gets the index of the dealer in player pool. Like 3
		for index in range(i,(i+4)):			# For a 4 count range from the index.. Like [3,4,5,6]
			var player = playerpool[index%4]	# %4 loops back to 0 for indexes..  Like [3,0,1,2]
			if pass_count == 3:							# If 3 pass in a row, break loop.
				break
			if player.human:					# Calls window of human bet
				$SFX/Card_PopUp.play(.25)
				await call_bet_window()					# Calls Human betting screen
				bet_label()								# Updates bet label in center of mat.
				await get_tree().create_timer(1,false).timeout
			else:
				await player.ai_bid()			# Calls function for AI bet.
		if pass_count == 3:
			break
	$SFX/Card_Ding.pitch_scale = 0.69
	$SFX/Card_Whiff.pitch_scale = 0.62
	bet_label()									# Updates bet label, redundancy.
	if current_better.name in team1: # team1 = ["Player1","Player3"], set's bet winning team.
		betting_team = "Team 1"
	else:
		betting_team = "Team 2"
	var message = str("Winner: ", betting_team, "\n\n\nBet: ", current_bet)
	if not Global.guides:
		message = str("Winner: ", betting_team, "\nBet: ", current_bet)
	if Global.variant_rules.bet_based_pips:
		if current_bet > 24:
			pip_change = 3
		elif current_bet > 19:
			pip_change = 2
	round_message(message,1)
	await timer(.5)
	dealer = current_better						#Bet winner starts the 1st hand.
	
	# Once loop breaks, this function completes and _ready() continues from await.


func call_bet_window(): # Human betting window called.
	$Player1/Hand.z_index = 5 									# Players moved to front of viewport. (5 is random high number)
	var bet_scene = load("res://betting_ui.tscn").instantiate() # Betting window readied.
	$"Black Fade".modulate = Color(1, 1, 1, 0.50)			# Fade the table behind to 50% black
	bet_scene.current_bid = current_bet
	if current_bet == 13 and Global.variant_rules.redeal:
		if $Player1.check_redeal():
			bet_scene.redeal = true
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
	
func bet_label():
	if not Global.guides:
		return
	$"UI/Bet Node/Bet Label".text = str("Bet:\n",current_bet)
	if current_better.name in team1:
		$"UI/Bet Node".modulate = Color.hex(0xff9203c4)
		$"UI/Bet Node/Bet Label/Arrow Team 1".visible = true
		$"UI/Bet Node/Bet Label/Arrow Team 2".visible = false
	else:
		$"UI/Bet Node".modulate = Color(0.01, 0.57, 1, 0.77)
		$"UI/Bet Node/Bet Label/Arrow Team 1".visible = false
		$"UI/Bet Node/Bet Label/Arrow Team 2".visible = true
	$"UI/Bet Node/Bet Label".visible = true

func final_bet():
	if betting_team == "Team 1":
		$Player1/Hand.z_index = 5 									# Players moved to front of viewport. (5 is random high number)
		var bet_scene = load("res://final_bet.tscn").instantiate() # Betting window readied.
		$"Black Fade".modulate = Color(1, 1, 1, 0.50)			# Fade the table behind to 50% black
		bet_scene.current_bid = current_bet
		$PopUp.add_child(bet_scene)										# Add the window to the root of scene.
		var bet = await bet_scene.bid_24		# Pause until signal returns bet or pass.
		if bet: 												# bet returns value (true)
			current_bet = bet									# store players returned bet
			print('Player Bet: ',bet)
			if Global.variant_rules.bet_based_pips:
				pip_change = 2
			bet_label()
		$Player1/Hand.z_index = 0								# Return cards to normal layer.
		bet_scene.queue_free()									# Kill the betting window.
		$"Black Fade".modulate = Color(1, 1, 1, 0)				# Remove 50% black fade.
		
		pass
	else: #if team 2 (AI team)
		var team_goal = ($Player2.bet_goal + $Player4.bet_goal)*.5 + (randi() % 6)
		if team_goal  >= 24:
			current_bet = 24
			print('Bot Bet: 24')
			if Global.variant_rules.bet_based_pips:
				pip_change = 2
			$SFX/Card_Ding.play()
			bet_label()
	
	
	
func trump_stage():
	var trump_sprite = $"UI/Trump Card/Trump Sprite"
	$SFX/Card_PopUp.play(.25)
	trump_suit = await current_better.pick_trump() 			# Calls for the bid winner to process trump choice (Player.gd)
	if current_better.human:
		var assemble = str("res://Assets/Cards/PNG/Cards/",trump_suit,"_trump.png")
		trump_sprite.texture = load(assemble)
		trump_sprite.modulate = Color(0.61000001430511, 0.61000001430511, 0.61000001430511)
	if not Global.guides and current_better.human:
		trump_sprite.position.x = -468
		get_tree().create_tween().tween_property(trump_sprite,'scale',Vector2(1.5,1.5),.35).set_ease(Tween.EASE_IN)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(trump_sprite,'position',Vector2(-509,185),.75)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SPRING)
		await timer(2.25)
		trump_sprite.texture = load("res://Assets/Cards/PNG/Cards/cardBack_red4.png")
		await timer(.5)
	var tween= get_tree().create_tween() 				# Slides trump card in. TODO:(AI:Face down, Human:Face up.)
	tween.tween_property(trump_sprite,'position',Vector2(0,0),.75)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SPRING)
	get_tree().create_tween().tween_property(trump_sprite,'scale',Vector2(1,1),.35).set_ease(Tween.EASE_IN)

	





func trump_reveal(): # TODO trump face_up if player wins or revealed during play.
	var assemble = str("res://Assets/Cards/PNG/Cards/",trump_suit,"_trump.png")
	$"UI/Trump Card/Trump Sprite".texture = load(assemble)
	trump_revealed = true
	await timer(1)
	for hand in handpool:
		for card in hand.get_children():	#@TEST for trump outline mechanic. 
			card.trump_check()					# Enable to highlight trumps when player wins
	for playslot in get_tree().get_nodes_in_group("Playslots"):
		var card = playslot.get_child(0)
		if not card:
			continue
		if card.trump_check():
			if card.rank > leading_card:
				leading_card = card.rank
	if Global.variant_rules.pair:
		pair_flag = true

func pairs_check():
	await timer(.25)
	var pair_player
	var pair = []
	for hand in handpool:
		var cards = hand.get_children()
		for card in cards:
			if card.face in ["Q","K"] and card.suit == trump_suit:
				pair.append(card)
				print(hand.get_parent()," found pair: ",card.face,card.suit)
		if pair.size() == 2:
			pair_player = hand.get_parent()
			break
		else:
			pair.clear()
	if pair_player:
		for each in pair:
			each.face_up()
			each.position.y = -20
		await timer(.5)
		if pair_player.team == betting_team:
			current_bet -= 4
			round_message(str(pair_player.team, " has the pair.\n Decreasing bid by 4 points"),2.5)
			print(pair_player.team, betting_team)
		else:
			current_bet += 4
			print(pair_player.team, betting_team)
			round_message(str(pair_player.team, " has the Pair.\n Increasing bid by 4 points"),2.5)
		await timer(3.5)
		for each in pair:
			if not pair_player.human:
				each.face_down()
			each.position.y = 0
		bet_label()

func game_stage(): # A loop of 8 tricks is played.
	for cards in $Player1/Hand.get_child_count():									# 8 cards per hand, 8 rounds per game.
		await play_trick()
	
	
func pip_stage():
	##*** SCOREING TIME ***##
	team_points = 0
	for player in playerpool:
		print(player, " has ",player.points)
		if player.team == betting_team:
			team_points += player.points 
	var message
	if team_points >= current_bet:
		message = str(betting_team, ' WINS the round.')
		bet_won = true
		#if betting_team == "Team 1":
			#team1_pips += pip_change
		#else:
			#team2_pips += pip_change
	else:
		message = str(betting_team, ' LOSES the round.')
		pip_change +=1
		bet_won = false
		#if betting_team == "Team 1":
			#team1_pips -= pip_change+1
			#
		#else:
			#team2_pips -= pip_change+1
	var pip_scene = load("res://pip_score.tscn").instantiate()
	$PopUp.add_child(pip_scene)
	await $"PopUp".child_exiting_tree
	
	pip_update()
	await round_message(message,3)
	
	if team1_pips >= 6 or team2_pips <= -6:
		$"Team 1".z_index += 4
		$"Team 2".z_index += 4
		get_tree().create_tween().tween_property($"Team 1","position",Vector2(409,265),.35).set_trans(Tween.TRANS_BACK)
		await get_tree().create_tween().tween_property($"Team 2","position",Vector2(47,308),.35).set_trans(Tween.TRANS_BACK).finished
		$"SFX/Match Win Lose".play()
		await round_message("TEAM 1 WINS THE MATCH",4)
		await get_tree().create_tween().tween_property($"Play again?","position",Vector2(502,313),.33).set_trans(Tween.TRANS_SPRING).finished
		await $"Play again?".pressed
		get_tree().reload_current_scene()
		return
	
	elif team2_pips >= 6 or team1_pips <= -6:
		$"Team 1".z_index += 4
		$"Team 2".z_index += 4	
		var goal_spot1 = $"Team 1".position+Vector2(380,-330)
		var goal_spot2 = $"Team 2".position+Vector2(380,-330)
		$"SFX/Match Win Lose".stream = load("res://Assets/SFX & Music/match failure.wav")
		get_tree().create_tween().tween_property($"Team 1","position",goal_spot1,.35).set_trans(Tween.TRANS_BACK)
		await get_tree().create_tween().tween_property($"Team 2","position",goal_spot2,.35).set_trans(Tween.TRANS_BACK).finished
		$"SFX/Match Win Lose".play()
		await round_message("TEAM 2 WINS THE MATCH",4)
		await get_tree().create_tween().tween_property($"Play again?","position",Vector2(502,313),.33).set_trans(Tween.TRANS_SPRING).finished
		await $"Play again?".pressed
		get_tree().reload_current_scene()
		return
	else:
		initialize()
	
	
	
func pip_update():
	$"Team 1".z_index += 4
	$"Team 2".z_index += 4
	get_tree().create_tween().tween_property($"Team 1","scale",Vector2(1.5,1.5),.35).set_trans(Tween.TRANS_BACK)
	await get_tree().create_tween().tween_property($"Team 2","scale",Vector2(1.5,1.5),.35).set_trans(Tween.TRANS_BACK).finished
	for n in pip_change:
		await timer(.45)
		$SFX/Pip_Pop.play()
		if betting_team == "Team 1":
			if bet_won:
				team1_pips +=1
			else:
				team1_pips -=1
		else:
			if bet_won:
				team2_pips +=1
			else:
				team2_pips -=1
		$"Team 1".value = abs(team1_pips)
		if team1_pips < 0:
			$"Team 1".self_modulate = Color(0, 0, 0)
		else:
			$"Team 1".self_modulate = Color(1,1,1)
		$"Team 2".value = abs(team2_pips)
		if team2_pips < 0:
			$"Team 2".self_modulate = Color(0, 0, 0)
		else:
			$"Team 2".self_modulate = Color(1,1,1)
	await timer(1)
	get_tree().create_tween().tween_property($"Team 1","scale",Vector2(1,1),.35).set_trans(Tween.TRANS_BACK)
	await get_tree().create_tween().tween_property($"Team 2","scale",Vector2(1,1),.35).set_trans(Tween.TRANS_BACK).finished
	$"Team 1".z_index += 4
	$"Team 2".z_index += 4


func play_trick():
	# *** Play the trick *** #
	leading_card = 0
	for hand in handpool:					
		for card in hand.get_children():
			card.enable_card()				# Re-enable all cards for next trick.
	var i = playerpool.find(dealer) 		# Gets the index of the dealer in player pool. Like 3
	for index in range(i,(i+4)):			# For a 4 count range from the index.. Like [3,4,5,6]
		var player = playerpool[index%4]	# Sets the player by index using mods 4 to wrap around to 0. Like 3,0,1,2
		print('\n',player.name,"'s turn!")
		await player.play_turn()			# Calls to the current player to to play a card.
		print("Leading card value: ",leading_card)
		await timer(.75)
	print('\n*** Trick Complete ***\nStarting scoring..')
	
	# *** Decide the Winner *** #
	for playslot in get_tree().get_nodes_in_group('Playslots'): # Array of all playslots
		var player = playslot.get_parent()
		var card = playslot.get_child(0)
		if card.suit == trick_suit:
			if card.rank >= trick_winner[1]:				# If card in suit, does it leader?
				print(player,card.rank," beats ", trick_winner)
				trick_winner = [player,card.rank]			# Yes, Highest card in suit is New leader
			else:
				pass										# No, it's garbage.
		elif card.suit == trump_suit and trump_revealed:	# If not in suit, is it a trump? 
			trick_suit = trump_suit 						# Yes, Suit changes to trump now.
			trick_winner = [player,card.rank]				# Player is new leader.
		else:
			pass											# Not current suit, it's garbage.
	
	# *** Announce the Winner *** #
	var winning_card = trick_winner[0].get_node("Playslot").get_child(0)
	await get_tree().create_tween()\
			.tween_property(winning_card,'modulate',Color(0.48432621359825, 0.875, 0.44091796875),.32)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SPRING).finished			# Highlight winning card slightly
	await round_message(str(trick_winner[0].name, " wins!"),1.5)# Display Round winner
	await get_tree().create_tween()\
			.tween_property(winning_card,'modulate',Color(1, 1, 1),.32)\
			.set_ease(Tween.EASE_OUT)\
			.set_trans(Tween.TRANS_SPRING).finished 
	var sum = 0
	for playslot in get_tree().get_nodes_in_group('Playslots'):
		var card = playslot.get_child(0)
		sum += card.value
		card.slot = (trick_winner[0].get_node("Hand")\
				.to_global(Vector2(205,400)))				# Store vector 400 pixels off screen past winner.
		card.go_and_die()									# Winning cards fly to that point.
		await timer(0.08)									
	trick_winner[0].points += sum							# Give the player his points.
	var trick_score_scene = load("res://trick_score.tscn").instantiate()
	trick_score_scene.points = sum
	if Global.guides:
		$PopUp.add_child(trick_score_scene)
		await $"PopUp".child_exiting_tree
	print(trick_winner," won trick worth ", sum,' points!')
	dealer = trick_winner[0]
	trick_winner = ["null",0]
	leading_card = 0
	if pair_flag:
		pair_flag = false
		await timer(1)
		await pairs_check()
	await timer(1)





func round_message(message : String,duration):	# Template for making a message fade in center of screen.
	var label = $"Round Message"
	label.text = message
	await get_tree().create_tween()\
			.tween_property(label,"modulate",Color(1, 1, 1,1),.35)\
			.set_ease(Tween.EASE_IN_OUT).finished	# No delay for fade in.
	await get_tree().create_tween()\
			.tween_property(label,"modulate",Color(1, 1, 1,0),.35)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(duration).finished			# Duration delay before fades out.
	
	
## THE EVER IMPORTANT DRAW CARD FUNCTION ##
func draw_card(hand):	
	if not drawpile.size():					# If drawpile array is empty
		print('Draw pile empty, dumbass')
		return 0							# False value for error, stop draws.
	var face_show = true if hand.get_parent().human else false #if human, card faceup
	var children = hand.get_children()	# How many cards already in hand.
	# Requests card object from constructor script, configured using an ID from top of drawpile.
	if children.size() == MAX_HANDSIZE:			# Skip hand if hand is full.
		('Hands full, greedy pig boy!')
		return 1							# return true because we skip, not stop.
	var new_card = $CardConstructor.newcard(drawpile.pop_back(),face_show)
	var j = sort_hand(children,new_card)
	hand.add_child(new_card)				# Add card object to scene under requesting hand.
	new_card.global_position = $DrawDeck.global_position - Vector2(-64,-64) # position center of draw deck
	new_card.grow_and_go() # Tween animations of scale-up and move-to stored position in hand.
	for each in children:		# For each card still in hand
		each.go()							# Tween them there.
	$SFX/Card_Fwip.play(.11)		# Card SFX
	$DrawDeck/Amount.text = str(drawpile.size()) # Refresh the amount label on drawdeck.
	if drawpile.size() == 0:					# If that was last card, make drawdeck disappear.
		$DrawDeck.visible = false
	hand.move_child(new_card,j)
	return 1									# True value for success

	

func play_card(card): # Click cards are moved to their assigned playslot
	var player = card.get_node("../..") 		# "../.." means parent of my parent.
	var playslot = player.get_node("Playslot")  # store playslot object
	if playslot.get_child_count():				# If playslot has card, cancel function.
		return
	var slot = Vector2(0,0)					# stores a base position.
	card.slot = slot						# Updates the card's variable for upcoming tween.
	card.reparent(playslot)					# Moves card object from hand to playslot
	if playslot == $Player3/Playslot:
		card.get_node("Label").set_rotation_degrees(180)
	card.go()								# Tweens to playslot's base position (0,0)
	card.inplay = true						# Set flag in objects variables.
	card.selected = false
	card.get_node("shadow").visible = false # Removes shadow (laying flat on table)
	$SFX/Card_Fwip.play()						# SFX
	if not player.human:
		var cards = player.get_node("Hand").get_children()
		var offset = Vector2(140-(20*(cards.size()-1)),0)
		for each in cards:		# For each card still in hand
			each.slot = offset					# Update card with new spot in hand.
			each.go()							# Tween them there.
			offset += Vector2(40,0)				# Increase for next card.
	await timer(.5)
	card_played.emit()

	
func take_card(card): # An inversion of play_card() move playslot card back to hand.
	card.z_index -=2
	card.label_off()
	var hand = $Player1/Hand
	var children = hand.get_children()
	var j = sort_hand(children,card)
	print(j)
	card.selected = false
	get_tree().create_tween().tween_property(card.get_node("shadow"),"position",Vector2(-6,3),.20)
	card.reparent(hand,true)
	#await timer(.25)
	for each in hand.get_children():
		each.go()
	hand.move_child(card,j)
	$SFX/Card_Fwip.play(.11)
	return 1
	
	
func _on_deal_all_pressed(): ## NOTE: Used by Director and Deal all button. Deals 4 cards to ALL.
	var time=0.45					# Time between each card.
	$SFX/Card_Fwip.pitch_scale = .69	# Card SFX
	for n in 4:						# For 4 cards
		for hand in handpool:		# For each hand
			if not draw_card(hand):	# Run Draw_card(), if return 0, empty draw deck.
				return
			await get_tree().create_timer(time,false).timeout # wait 'time' before next card
			$SFX/Card_Fwip.pitch_scale += .01 # Raise SFX pitch a little each card
			time = time+.005-(time*time) # Decrease time between cards for speed up
	$SFX/Card_Fwip.pitch_scale = .69		# Reset SFX pitch when done.


func _on_discard_button_pressed(): # Discards all hands to discard pile. 
	## NOTE: Tied to a button, no  use in real game as cards would go to trick piles, not discard.
	## So I need to retool this into 4 player-trick decks.. or 2 team-trick decks
	var time=0.40					# Time between each card.
	$SFX/Card_Fwip.pitch_scale = .69	# Card SFX
	for hand in handpool:			# For each hand.
		for card in hand.get_children():	# For each card in each hand
			var id = card.get('id')			# Get their ID.
			drawpile.append(id)			# Dump ID into discard array.
			card.go_and_redeal()				# tween from position to draw_deck.
			await get_tree().create_timer(time,false).timeout #wait 'time' before next card 
			$DrawDeck/Amount.text = str(drawpile.size()) # Update discarddeck label
			$SFX/Card_Fwip.play()				# SFX
			$SFX/Card_Fwip.pitch_scale += .01	# Raise SFX pitch a little each card
			time = time+.005-(time*time)	# Decrease time between cards for speed up
	$SFX/Card_Fwip.pitch_scale = .69			# Reset SFX pitch when done.
	drawpile.shuffle()
	emit_signal("move_on")


## Trigger for $flip_cards button
func _on_flip_cards_pressed(): # Useless button for flipping cards for fun.
	$SFX/Card_Fwip.play(.07)		# SFX
	var cards = $Player1/Hand.get_children()	# Get cards in Player1 hand.
	for card in cards:			# For each card 
		card.face_toggle()		# run their face_toggle() inside their Player.gd



func _on_shuffle_pressed(): # Move IDs from Discardpile to Drawpile
	drawpile.append_array(discardpile)	# Copy IDs to drawpile.
	discardpile = []					# Delete IDs from discardpile
	$SFX/Card_Shuffle.play()		# SFX
	drawpile.shuffle()			# Shuffle IDs in drawpile
	deck_refresh()				# Visually referesh onscreen decks


func deck_refresh():	# Update labels and deck sprites. DEBUG TOOL
	var drawpile_size = drawpile.size()		
	var discardpile_size = discardpile.size()
	$Discard_Deck/Amount.text = str(discardpile_size)
	$DrawDeck/Amount.text = str(drawpile_size)
	$DrawDeck.visible = drawpile_size		#if 0 false, else true (truthy value)
	$Discard_Deck.visible = discardpile_size


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

func select_card(card):
	var old_card
	if $Player1/Selected.get_child_count():
		old_card = $Player1/Selected.get_child(0)
	card.reparent($Player1/Selected)
	var slot = Vector2(0,0)
	card.slot = Vector2(0,0)
	card.z_index +=2
	card.select_and_go()					# stores a base position.
	var cards = $Player1/Hand.get_children()
	var offset = Vector2(140-(20*(cards.size()-1)),0)
	for each in cards:		# For each card still in hand
		each.slot = offset					# Update card with new spot in hand.
		each.go()							# Tween them there.
		offset += Vector2(40,0)				# Increase for next card.
	if old_card:
		await take_card(old_card)

	#for each in cards:		# For each card still in hand
		#each.slot -= slot					# Update card with new spot in hand.
		#each.go()							# Tween them there.
		#slot += Vector2(40,0)				# Increase for next card.
	#if old_card:
		#await take_card(old_card)
	#pass



func _on_deal_one_card_pressed(): # Deal 1 card button. _on_deal_all_pressed()
	if not draw_card($Player1/Hand):
				return
	pass # Replace with function body


func _on_texture_button_2_toggled(): # Speeds up game-rate for dev inpatience.
	Engine.time_scale +=.5 if Engine.time_scale <2 else -1
	if Engine.time_scale == 2:
		$"Pause slot/TextureButton2/Label".text = "Fastest"
		$"Pause slot/TextureButton2".texture_normal = load("res://Assets/HyperCasual Game UI/SuperNextButton.png")
	elif Engine.time_scale == 1.5:
		$"Pause slot/TextureButton2/Label".text = "Faster"
		$"Pause slot/TextureButton2".texture_normal = load("res://Assets/HyperCasual Game UI/nextBtn.png")
	else:
		$"Pause slot/TextureButton2/Label".text = "Normal"
		$"Pause slot/TextureButton2".texture_normal = load("res://Assets/HyperCasual Game UI/playBtn.png")
	print ('engine timescale: ',Engine.time_scale)

	pass # Replace with function body. # Replace with function body.


func sort_hand(children,new_card):
	
	var i = 0
	var j = 0
	var found = false
	var cards = children.size()
	if children.size() == 0:
		new_card.slot = Vector2(140,0)
		return j
	for old_card in children:				# Position stored relative to amount of cards in hand.
		if new_card.id > old_card.id:
			old_card.slot = Vector2(i+140-(cards*20),0)
			j += 1
		else :
			if not found:
				new_card.slot = Vector2(i+140-(cards*20),0)
				found = true
				i+=40
			old_card.slot = Vector2(i+140-(cards*20),0)
		i += 40
	if not found:
		new_card.slot = Vector2(i+140-(cards*20),0)
	return j	


func _pip_update():
	team1_pips -=1
	pip_update()
	print(team1_pips)
	pass # Replace with function body.

func _player_redeal():
	await _on_discard_button_pressed()
	await _on_deal_all_pressed()
	await timer(.5)
	get_tree().call_group("Players", "ready_bid")


func _on_ui_icon_entered(node):
	var item = $"Pause slot".find_child(node).get_node("Label")
	item.visible = !item.visible
	$"Pause slot/TextureButton2/Label".text = "Game\nSpeed"


func guides_changed():
	if Global.guides == Global.FULL:
		var hand = $"Player1/Hand".get_children()
		for card in hand:	#@TEST for trump outline mechanic. 
			card.trump_check()					# Enable to highlight trumps when player wins
		for playslot in get_tree().get_nodes_in_group("Playslots"):
			var card = playslot.get_child(0)
			if not card:
				continue
			card.trump_check()
		if trump_revealed:
			var assemble = str("res://Assets/Cards/PNG/Cards/",trump_suit,"_trump.png")
			$"UI/Trump Card/Trump Sprite".texture = load(assemble)
	if not Global.guides >= Global.PARTIAL:
		bet_label()
