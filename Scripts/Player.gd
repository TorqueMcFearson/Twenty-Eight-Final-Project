extends Node2D

var matches = {}
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
	if human:
		return
	for card in $Hand.get_children():
		matches[card.suit] = matches.get(card.suit, 0) + 1
		points += card.value
	var suit_match = matches.values().max()
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
		var trump = matches.find_key(matches.values().max())
		return trump
