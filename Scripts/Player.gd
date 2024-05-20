extends Node2D

var matches = {}
var points = 0
var bet_goal = 0
var human = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ai_bid():
	if human or $"..".pass_count == 3:
		return
	var current_bet = $"..".current_bet 
	if current_bet < bet_goal:
		#print('Ideal Bet: ',bet_goal, ' upper bet range: ',(bet_goal-current_bet)/2+current_bet)
		randomize()
		var ai_bet = randi_range(current_bet+1,(bet_goal-current_bet)/2+current_bet)
		print(self.name,' bets:', ai_bet)
		$"..".current_bet  = ai_bet
		$"..".pass_count = 0
	else:
		$"..".pass_count += 1
		print(self.name,' AI PASSED! Count:', $"..".pass_count)
		

func ready_bid():
	if human:
		return
	for card in $Hand.get_children():
		matches[card.suit] = matches.get(card.suit, 0) + 1
		points += card.value
	matches = matches.values().max()
	bet_goal = (matches * 2) + (points/2) + 14
	print(self.name,': BID IS READY.',' Bet goal: ',bet_goal)
