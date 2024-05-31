extends Node2D
var team : String
var held_suits := {}
var points = 0
var value = 0
var bet_goal = 0
var human = false
var aggression = .5 # Modifies how range of how high they'll bet.
var trick_choice = "any" #trick, trump, trash, or any
@onready var label = $"/root/Director/Player Message" 
@onready var Director = $"/root/Director"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	aggression = randf_range(.5,.8)
	if name == "Player1" or name == "Player3":
		team = "Team 1"
	else:
		team = "Team 2"
	pass # Replace with function body.
	#var click_delay = create_timer()

func initialize():
	held_suits = {}
	points = 0
	value = 0
	bet_goal = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func ready_bid():
	held_suits.clear()
	for card in $Hand.get_children():
		held_suits[card.suit] = held_suits.get(card.suit, 0) + 1
		value += card.value
	if human:
		return
	var suit_match = held_suits.values().max()
	bet_goal = clampi((suit_match * 2) + (value/2) + 14 - (4-Global.difficulty),14,28)
	print(self.name,': BID IS READY.',' Bet goal: ',bet_goal,' Aggression :',aggression)
	
	
func ai_bid():
	if human or Director.pass_count == 3:
		return
	var current_bet = Director.current_bet
	if current_bet == 13:
		if await check_redeal():
			await redeal()
	var message : String
	var min_bet = current_bet+1
	if Global.variant_rules.partner_bid and Director.current_better.team == team:
		print("same team, clamping to 20 min bet.")
		min_bet = clamp(min_bet,20,99)
		pass
	var color = Color(1, 1, 1,1)
	if current_bet < bet_goal or current_bet == 13:
		#print('Ideal Bet: ',bet_goal, ' upper bet range: ',(bet_goal-current_bet)/2+current_bet)
		randomize()
		var ai_bet = randi_range(min_bet,(bet_goal-min_bet)*aggression+min_bet)
		print(self.name,' bets:', ai_bet, ' for bet range of ', range(min_bet,(bet_goal-min_bet)*aggression+min_bet+1))
		Director.current_bet  = ai_bet
		Director.pass_count = 0
		Director.current_better = $"."
		Director.bet_label()
		message = "Player Bet %s" %ai_bet
		$"../SFX/Card_Whiff".pitch_scale = .65
		$"../SFX/Card_Ding".pitch_scale = ai_bet*.02+.41
		$"../SFX/Card_Ding".play()
	else:
		color = Color(1, 1, 1,.65)
		Director.pass_count += 1
		print(self.name,' AI PASSED! Count:', Director.pass_count)
		message = "Player Passed"
		$"../SFX/Card_Whiff".pitch_scale += .03
		$"../SFX/Card_Whiff".play()
	await player_message(message,color,0.4)
	

func player_message(message,color,duration):
	label.text = message
	var rise = Vector2(0,5)
	label.position = position + rise
	get_tree().create_tween()\
			.tween_property(label,"modulate",color,.25)\
			.set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_tween()\
			.tween_property(label,"position",label.position-rise,.25)\
			.set_ease(Tween.EASE_OUT).finished
	color.a = 0
	get_tree().create_tween()\
			.tween_property(label,"position",label.position-rise,.35)\
			.set_ease(Tween.EASE_IN)\
			.set_delay(duration)	
	await get_tree().create_tween()\
			.tween_property(label,"modulate",color,.35)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(duration).finished

func pick_trump():
	if human:
		$Hand.z_index = 5 # Players moved to front of viewport. (5 is random high number)
		var trump_pick_scene = load("res://Trump Pick.tscn").instantiate() # Betting window readied.						# Scene is informed of current bet
		$"../Black Fade".modulate = Color(1, 1, 1, 0.50)			# Fade the table behind to 50% black
		$"../PopUp".add_child(trump_pick_scene)						# Add the window to the root of scene.
		var trump = await get_node("../PopUp/Trump Pick").trump_picked
		 # Pause until signal returns bet or pass.
		$Hand.z_index = 0								# Return cards to normal layer.
		trump_pick_scene.queue_free()									# Kill the betting window.
		$"../Black Fade".modulate = Color(1, 1, 1, 0)				# Remove 50% black fade.
		return trump
	
	else:
		var trump = held_suits.find_key(held_suits.values().max())
		return trump

# We check for first turn.
# Notes first we check what cards we can play
# Then we adjust cards as disabled.
# 
func play_turn():
	var card
	if human:
		Director.round_message("Your Turn", 1)
		if self != Director.dealer:
			await disable_cards()
		Global.cards_playable = true
		print("***Human cards UNLOCKED****")
		await Director.card_played
		Global.cards_playable = false
		print("***Human cards LOCKED****")
		card = $Playslot.get_child(0)
			
	else: #AI Turn
		if self != Director.dealer:
			await disable_cards()
		else:
			trick_choice = "any"
		var cards = get_node("Hand").get_children()
		var playable_cards = []
		for each in cards:
			if not each.disabled:
				playable_cards.append(each)
		if trick_choice == "trick":
			if playable_cards.any(func(x): return x.rank > Director.leading_card):
				print("Has suit and can beat. Playing best card.")
				card = playable_cards.back()
			else:
				print("Has suit but can't beat. Playing worst card.")
				card = playable_cards.front()
		elif trick_choice == "trump":
			var playable_trump = playable_cards.filter(func(x): return (x.trump and x.rank > Director.leading_card))
			if playable_trump.is_empty():
				print("Has trump but can't beat. Playing worst trash card.")
				card = playable_cards.filter(func(x): return (not x.trump))
			else:
				print("Has trump and can beat. Playing best trump card.")
				card = playable_trump.back()
		elif trick_choice == "trash":
			print("Has Trash, playing worst card.")
			card = playable_cards.front()
		elif trick_choice == "any":
			print("Is Dealer, playing any card.")
			card = playable_cards.pick_random()
		card.face_up()
		card.trump_check()
		Director.play_card(card)
		await Director.card_played
	held_suits[card.suit] -= 1
	if self == Director.dealer:
		Director.trick_suit = $Playslot.get_child(0).suit
	if card.suit != Director.trick_suit and (card.suit != Director.trump_suit or not Director.trump_revealed):
		card.get_node('CardBack').modulate = Color(0.85, 0.85, 0.85)
	if card.rank > Director.leading_card and (card.suit == Director.trick_suit or (card.suit == Director.trump_suit and Director.trump_revealed)):
		Director.leading_card = card.rank
	print(name, " played %s of %s worth %s" %[card.face,card.suit,card.rank])
	

func disable_cards():
	var cards = get_node("Hand").get_children()
	if held_suits.get(Director.trick_suit):
		for card in cards:
			if card.suit == Director.trick_suit:
				trick_choice = "trick"
			else:
				card.disable_card()
	elif Director.trump_revealed and held_suits.get(Director.trump_suit):
		trick_choice = "trump"
	elif Director.trump_revealed:
		trick_choice = "trash"
	else:
		Director.trump_reveal()
		await player_message(str("I need to \nsee the trump"),Color(1,1,1),2)
		$"../UI/Trump Card/Trump Sprite".modulate = Color(1, 1, 1)
		$"../UI/Trump Card/Label".add_theme_color_override("font_color", Color(1, 1, 1,.16))
		$"../UI/Trump Card/Label2".add_theme_color_override("font_color", Color(1, 1, 1,.16))
		disable_cards()

func check_redeal():
	var cards = $Hand.get_children()
	for card in cards:
		print("redeal value: ", card.value)
		if card.value:
			return 0
	print("no values found")
	return 1
	
func redeal():
	await player_message("Requesting redeal.",Color(1, 1, 1),1)
	await Director._on_discard_button_pressed()
	await get_tree().create_timer(.75).timeout
	await Director._on_deal_all_pressed()
	await Director.timer(.5)
	get_tree().call_group("Players", "ready_bid")
	
#DEPRECATED: Director now calls for this directly (pun unintended).
#func enable_cards(): 
	#var active_suits = [Director.trick_suit]
	#if Director.trump_reveal:
		#active_suits.append(Director.trump_suit)
	#for card in get_node("Hand").get_children():
		#if card.suit in active_suits:
			#card.enable_card()
