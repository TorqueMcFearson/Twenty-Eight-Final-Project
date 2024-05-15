extends Node2D

const MAX_HANDSIZE = 8
 
var drawpile = range(32)
var discardpile = []

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

func draw_card(to_hand):
	var children = to_hand.get_child_count()
	var new_card = $CardConstructor.newcard(drawpile.pop_back())
	if not new_card:
		return 0
	var x_offset = to_hand.get_child_count()
	new_card.position.x += x_offset*40
	to_hand.add_child(new_card)
	$DrawDeck/Amount.text = str(drawpile.size())
	if drawpile.size() == 0:
		butt_off()
		$DrawDeck.visible = false
	return 1

func _on_button_pressed():
	butt_off()
	draw_card($Player1/Hand)
	butt_check()
	pass # Replace with function body.

func reset_button_pressed():
	if not $Player1/Hand.get_child_count():
		print(" Can't.. empty hand, Dummy")
		return
	var node = $Player1/Hand
	for n in node.get_children():
		var card = n.get('id')
		discardpile.append(card)
		node.remove_child(n)
		n.queue_free()
	$Discard_Deck/Amount.text = str(discardpile.size())
	butt_check()
	$Discard_Deck.visible = true

	pass # Replace with function body.

func draw_full_hand_pressed():
	butt_off()
	var time= 0.28
	var sum = 0.0
	for n in range($Player1/Hand.get_child_count(),MAX_HANDSIZE):
		if not draw_card($Player1/Hand):
			break
		await get_tree().create_timer(time).timeout
		sum += time
		time = (time/3)+.07
	butt_check()
	pass # Replace with function body.

func butt_check():
	if not drawpile.size():
		reset_on()
	elif $Player1/Hand.get_child_count() == 8:
		reset_on()
	else:
		butt_on()

func butt_on():
	$Draw_Button.disabled = false
	$Draw_Full_Button.disabled = false
	$Reset_Button.disabled = false
func butt_off():
	$Draw_Button.disabled = true
	$Draw_Full_Button.disabled = true
	$Reset_Button.disabled = true
func reset_on():
	$Reset_Button.disabled = false
func reset_off():
	$Reset_Button.disabled = true
	
