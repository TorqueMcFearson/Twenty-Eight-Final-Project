extends Node2D

const MAX_HANDSIZE = 8
 
var drawpile = range(32)
var discardpile = []
@onready var dealerpool = [$Player1,$Player2,$Player3,$Player4]
@onready var handpool = [$Player1/Hand, $Player2/Hand, $Player3/Hand, $Player4/Hand]
# Called when the node enters the scene tree for the first time.

func _ready():
	$Discard_Deck.visible = false
	$DrawDeck/Amount.text = str(drawpile.size())
	drawpile.shuffle()
	var cardlist = []
	for each in drawpile:
		var data = Database.cards.get(each)
		cardlist.append(data.face + " of " + data.suit)
	
	for each in cardlist:
		print(each)
	print("^Drawpile in reverse order^")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# variable = value1 if condition else: value2
func draw_card(to_hand):
	if not drawpile.size():
		print('Draw pile empty, dumbass')
		return 0
	var face_show = true if to_hand == $Player1/Hand else false
	var children = to_hand.get_child_count()
	var new_card = $CardConstructor.newcard(drawpile.pop_back(),face_show)
	var x_offset = children
	new_card.position.x += x_offset*40
	to_hand.add_child(new_card)
	$DrawDeck/Amount.text = str(drawpile.size())
	if drawpile.size() == 0:
		butt_off()
		$DrawDeck.visible = false
	return 1

func reset_button_pressed():
	var hands = $Player1/Hand.get_children()
	if not hands:
		print("Hands are empty, dummy!")
		return
	for hand in handpool:
		for n in hand.get_children():
			var card = n.get('id')
			discardpile.append(card)
			hand.remove_child(n)
			n.queue_free()
	$Discard_Deck/Amount.text = str(discardpile.size())
	butt_check()
	$Discard_Deck.visible = true

	pass # Replace with function body.

func _on_deal_all_pressed():
	butt_off()
	var time=0.45
	for n in MAX_HANDSIZE/2:
		for hand in handpool:
			if not draw_card(hand):
				butt_check()
				return
			await get_tree().create_timer(time).timeout
			time = (time/2)+.03
	butt_check()

func _on_flip_cards_pressed():
	var cards = $Player1/Hand.get_children()
	for card in cards:
		card.face_toggle()

func butt_check():
	if not drawpile.size():
		reset_on()
	elif $Player1/Hand.get_child_count() == 8:
		reset_on()
	else:
		butt_on()

func butt_on():
	$Reset_Button.disabled = false
	$Deal_ALL.disabled = false
func butt_off():
	$Reset_Button.disabled = true
	$Deal_ALL.disabled = true
func reset_on():
	$Reset_Button.disabled = false
func reset_off():
	$Reset_Button.disabled = true


func _on_shuffle_pressed():
	reset_button_pressed()
	drawpile.append_array(discardpile)
	discardpile = []
	drawpile.shuffle()
	deck_refresh()
	pass # Replace with function body.
	
func deck_refresh():
	butt_on()
	var drawpile_size = drawpile.size()
	var discardpile_size = discardpile.size()
	$Discard_Deck/Amount.text = str(discardpile_size)
	$DrawDeck/Amount.text = str(drawpile_size)
	$DrawDeck.visible = drawpile_size
	$Discard_Deck.visible = discardpile_size
	print('drawpile =', drawpile)
	print('discardpile =', discardpile)
	print("deck refreshed")
	butt_check()
	
