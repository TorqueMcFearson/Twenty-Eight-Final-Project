extends Node2D

const MAX_HANDSIZE = 8

var drawpile = range(32)
var discardpile = []
@onready var dealerpool = [$Player1,$Player2,$Player3,$Player4]
@onready var handpool = [$Player1/Hand, $Player2/Hand, $Player3/Hand, $Player4/Hand]
var fade_goal = Color(1,1,1,0)
var fade_rate = .01
var current_bet = 14
@onready var current_better = $Player1
var round = 0
var pass_count = 0
	

# Called when the node enters the scene tree for the first time.
func _ready(): 
	# NOTE: Some elements are disabled/non-visible so I can see them in editor, but not at gamestart.
	$"Black Fade".visible = true # Rectangle $"Black Fade" covers the screen, it's used to fade in and out.
	$Discard_Deck.visible = false # Hides Discard deck until cards are in it.
	$DrawDeck/Amount.text = str(drawpile.size()) #Changes Deck Label to display amount in it.
	$Shuffle.disabled = true # Shuffle starts disabled because drawpile full
	$Discard_Button.disabled = true # Discard pile starts disabled, No cards in hands.
	$Player1.human = true
	# NOTE:Database.gd is AutoLoaded into game, so it's in every scene.
	drawpile.shuffle() #Shuffles the array of 31 IDs in drawpile.
	var cardlist = [] ## Debug tool: Just prints to console the draw cirds in order
	for each in drawpile: 
		var data = Database.cards.get(each)
		cardlist.append(data.face + " of " + data.suit)
	for each in cardlist:
		print(each)
	print("^Drawpile in reverse order^")
	$Discard_Deck/Amount.text = ''
	
	await get_tree().create_timer(1).timeout
	_on_deal_all_pressed()
	
	await get_tree().create_timer(3).timeout
	get_tree().call_group("Players", "ready_bid")
	await betting_round()
	trump_round()

func _process(delta):
	fade_in(delta)
	
func betting_round():
	while true:
		round +=1
		print ('\n *****Round ',round, '******\n')
		await Call_betting()
		await get_tree().create_timer(1).timeout
		get_tree().call_group("Players", "ai_bid")
		if pass_count == 3:
			break
	print("Winner: ", current_better.name, " Bet: ", current_bet)
	
func trump_round():
	if current_better.human:
		print("THIS WOULD GO TO TRUMP PICK.")
	else:
		current_better.pick_trump()
	
func second_deal():
	_on_deal_all_pressed()
	
func Call_betting():
	$Player1/Hand.z_index = 5
	var betscene = load("res://betting_ui.tscn").instantiate()
	betscene.current_bid = current_bet
	$"Black Fade".modulate = Color(1, 1, 1, 0.475)
	add_child(betscene)
	var bet = await get_node("BettingUI").bet_or_pass
	if not bet:
		pass_count += 1
		print('Player Passed! Count:', pass_count)
		
	else:
		pass_count = 0
		current_bet = bet
		current_better = $Player1
		print('Player Bet: ',bet)
	$Player1/Hand.z_index = 5
	betscene.queue_free()
	$"Black Fade".modulate = Color(1, 1, 1, 0)


## THE EVER IMPORTANT DRAW CARD FUNCTION
func draw_card(to_hand):
	if not drawpile.size():
		print('Draw pile empty, dumbass')
		return 0
	var face_show = true if to_hand.get_parent().human else false
	var children = to_hand.get_child_count()
	var new_card = $CardConstructor.newcard(drawpile.pop_back(),face_show)
	var x_offset = children
	new_card.slot = Vector2(children*40,0)
	new_card.position = new_card.slot
	to_hand.add_child(new_card)
	new_card.global_position = $DrawDeck.global_position - Vector2(-64,-64)
	new_card.grow_and_go(to_hand)
	$Card_Fwip.play(.11)
	$DrawDeck/Amount.text = str(drawpile.size())
	if drawpile.size() == 0:
		butt_off()
		$DrawDeck.visible = false
	return 1
	

func reset_button_pressed():
	butt_off()
	var time=0.40
	$Card_Fwip.pitch_scale = .69
	var hands = $Player1/Hand.get_children()
	if not hands:
		print("Hands are empty, dummy!")
		return
	var killtimer = get_tree().create_timer(4)
	$Discard_Deck.visible = true
	for hand in handpool:
		for card in hand.get_children():
			var id = card.get('id')
			discardpile.append(id)
			card.go_and_die()
			await get_tree().create_timer(time).timeout
			$Discard_Deck/Amount.text = str(discardpile.size())
			$Card_Fwip.play()
			$Card_Fwip.pitch_scale += .01
			time = time+.005-(time*time)
			
	butt_check()
	await killtimer.timeout
	print('hand children ',$Player1/Hand.get_children())
	pass # Replace with function body.
	
	

### Trigger for $Deal_ALL button#
func _on_deal_all_pressed():
	butt_off()
	var time=0.40
	$Card_Fwip.pitch_scale = .69
	for n in MAX_HANDSIZE/2:
		for hand in handpool:
			if not draw_card(hand):
				butt_check()
				return
			await get_tree().create_timer(time).timeout
			$Card_Fwip.pitch_scale += .01
			time = time+.005-(time*time)
	$Card_Fwip.pitch_scale = .69
	butt_check()

## Trigger for $flip_cards button
func _on_flip_cards_pressed():
	$Card_Fwip.play(.07)
	var cards = $Player1/Hand.get_children()
	for card in cards:
		card.face_toggle()

## Screen Buttons state handlers
func butt_check():
	if not drawpile.size():
		reset_on()
	elif $Player1/Hand.get_child_count() >= 8:
		reset_on()
	else:
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


func _on_shuffle_pressed():
	
	drawpile.append_array(discardpile)
	discardpile = []
	$Card_Shuffle.play()
	drawpile.shuffle()
	deck_refresh()
	$Shuffle.disabled = true
	$Discard_Button.disabled = true
	print(drawpile)
	print(discardpile)
	pass # Replace with function body.
	
func deck_refresh():
	butt_on()
	var drawpile_size = drawpile.size()
	var discardpile_size = discardpile.size()
	$Discard_Deck/Amount.text = str(discardpile_size)
	$DrawDeck/Amount.text = str(drawpile_size)
	$DrawDeck.visible = drawpile_size
	$Discard_Deck.visible = discardpile_size
	$Shuffle.disabled = true
	butt_check()


	
func fade_in(delta):

	var fade_mod = $"Black Fade".get_modulate()
	$"Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.03
	if fade_mod.a <0.1:
		print("DONE")
		set_process(false)

func fade_out(delta):

	var fade_mod = $"Black Fade".get_modulate()
	$"Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.03
	if fade_mod.a <0.1:
		print("DONE")
		set_process(false)
		
## Cards that are clicked call this function passing 'self' in args
func playcard(card):
	if true:
		var hand = card.get_parent()
		var playslot = card.get_node("../../Playslot")
		card.slot = Vector2 (0,0)
		card.reparent(playslot)
		card.go()
		card.inplay = true
		card.get_child(3).visible = false
		$Card_Fwip.play()
		var slot = Vector2(0,0)
		for each in hand.get_children():
			each.slot = slot
			each.go()
			slot += Vector2(40,0)
	else:
		print('not yours')

func _on_deal_one_card_pressed():
	butt_off()
	if not draw_card($Player1/Hand):
				butt_check()
				return
	butt_check()
	pass # Replace with function body.

## THE EVER IMPORTANT TAKE CARD FUNCTION
## TODO : Set everything to position not global_position
## NOTE: Why? Global_positioning doesn't take into account the hands rotation.
##

func take_card(card):
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


