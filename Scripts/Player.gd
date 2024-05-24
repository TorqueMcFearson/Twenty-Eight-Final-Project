extends Node2D

var held_suits = {}
var points = 0
var bet_goal = 0
var human = false
var aggression = .5 # Modifies how range of how high they'll bet. 
@onready var label = $"../Player Message" 
@onready var director = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	aggression = randf_range(.5,1)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func ready_bid():
	for card in $Hand.get_children():
		held_suits[card.suit] = held_suits.get(card.suit, 0) + 1
		points += card.value
	if human:
		return
	var suit_match = held_suits.values().max()
	bet_goal = (suit_match * 2) + (points/2) + 14
	print(self.name,': BID IS READY.',' Bet goal: ',bet_goal,' Aggression :',aggression)
	
	
func ai_bid():
	if human or director.pass_count == 3:
		return
	var current_bet = director.current_bet
	var message : String
	if current_bet < bet_goal:
		#print('Ideal Bet: ',bet_goal, ' upper bet range: ',(bet_goal-current_bet)/2+current_bet)
		randomize()
		var ai_bet = randi_range(current_bet+1,(bet_goal-current_bet)*aggression+current_bet)
		print(self.name,' bets:', ai_bet)
		director.current_bet  = ai_bet
		director.pass_count = 0
		director.current_better = $"."
		message = "Player Bet %s" %ai_bet 
	else:
		director.pass_count += 1
		print(self.name,' AI PASSED! Count:', director.pass_count)
		message = "Player Passed"
	await player_message(message)
		

func player_message(message):
	label.text = message
	var rise = Vector2(0,5)
	label.position = position+rise
	get_tree().create_tween()\
			.tween_property(label,"modulate",Color(1, 1, 1,1),.25)\
			.set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_tween()\
			.tween_property(label,"position",position,.25)\
			.set_ease(Tween.EASE_OUT).finished
	get_tree().create_tween()\
			.tween_property(label,"position",position-rise,.35)\
			.set_ease(Tween.EASE_IN)\
			.set_delay(.4)	
	await get_tree().create_tween()\
			.tween_property(label,"modulate",Color(1, 1, 1,0),.35)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_delay(.4).finished

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
	if human:
		print(director.trick_suit)
		Global.cards_playable = true
		if true: #self != director.dealer
			disable_cards()
		await $"../Play Card".pressed
	else:
		pass

func disable_cards():
	var active_suits: Array[String] = [director.trick_suit]
	var cards = get_node("Hand").get_children()
	if director.trump_reveal:
		active_suits.append(director.trump_suit)
	print("active: ",active_suits, " held: ", held_suits)
	if active_suits.any(func(x): return x in held_suits.keys()):
		print('active suits found in hand')
		print('Amount of cards: ',cards.size())
		for card in cards:
			if card.suit in active_suits:
				print (card.suit, ' is ', active_suits)
			else:
				print (card.suit, ' is not in ', active_suits)
				card.disable_card()
	else:
		if not director.trump_revealed:
			print("I need to see the trump")
			director.trump_reveal()
			disable_cards()
			return

func testfunc(x):
	print("testing testfunc: ", )

func enable_cards():
	var active_suits = [director.trick_suit]
	if director.trump_reveal:
		active_suits.append(director.trump_suit)
	for card in get_node("Hand").get_children():
		if card.suit in active_suits:
			card.enable_card()
