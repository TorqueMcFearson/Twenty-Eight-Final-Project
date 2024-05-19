extends Node2D

const MAX_HANDSIZE = 8

var drawpile = range(32)
var discardpile = []
@onready var dealerpool = [$Player1,$Player2,$Player3,$Player4]
@onready var handpool = [$Player1/Hand, $Player2/Hand, $Player3/Hand, $Player4/Hand]
var fade_goal = Color(0,0,0,0)
var fade_rate = .01
# Called when the node enters the scene tree for the first time.

func _ready():
	$"Black Fade".visible == true
	$Discard_Deck.visible = false
	$DrawDeck/Amount.text = str(drawpile.size())
	$Shuffle.disabled = true
	$Reset_Button.disabled = true
	drawpile.shuffle()
	var cardlist = []
	for each in drawpile:
		var data = Database.cards.get(each)
		cardlist.append(data.face + " of " + data.suit)
	for each in cardlist:
		print(each)
	print("^Drawpile in reverse order^")
	await get_tree().create_timer(2).timeout
	print('done')
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fade_in(delta)

	


func draw_card(to_hand):
	
	if not drawpile.size():
		print('Draw pile empty, dumbass')
		return 0
	var face_show = true if to_hand == $Player1/Hand else false
	var children = to_hand.get_child_count()
	var new_card = $CardConstructor.newcard(drawpile.pop_back(),face_show)
	var x_offset = children
	new_card.position.x += x_offset*40
	if to_hand == $Player1/Hand:
		if $Player1/Hand.get_child_count() == 0:
			new_card.find_child('shadow').position.x -= 15
		else:
			new_card.find_child('shadow').position.x -= 5
	to_hand.add_child(new_card)
	$Card_Fwip.play(.11)
	$Card_Fwip.pitch_scale += .01
	$DrawDeck/Amount.text = str(drawpile.size())
	if drawpile.size() == 0:
		butt_off()
		$DrawDeck.visible = false
	return 1

func reset_button_pressed():
	var hands = $Player1/Hand.get_children()
	$Card_Shuffle.play()
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
	var time=0.40
	$Card_Fwip.pitch_scale = .69
	for n in MAX_HANDSIZE/2:
		for hand in handpool:
			if not draw_card(hand):
				butt_check()
				return
			await get_tree().create_timer(time).timeout
			time = time+.005-(time*time)
			

	$Card_Fwip.pitch_scale = .69
	butt_check()

func _on_flip_cards_pressed():
	$Card_Fwip.play(.07)
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
	$Shuffle.disabled = false
	$Reset_Button.disabled = false
	$Deal_ALL.disabled = false
func butt_off():
	$Shuffle.disabled = true
	$Reset_Button.disabled = true
	$Deal_ALL.disabled = true
func reset_on():
	$Reset_Button.disabled = false
	$Shuffle.disabled = false
func reset_off():
	$Reset_Button.disabled = true
	$Shuffle.disabled = true


func _on_shuffle_pressed():
	reset_button_pressed()
	drawpile.append_array(discardpile)
	discardpile = []
	$Card_Shuffle.play()
	drawpile.shuffle()
	deck_refresh()
	$Shuffle.disabled = true
	$Reset_Button.disabled = true
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
	print('drawpile =', drawpile)
	print('discardpile =', discardpile)
	print("deck refreshed")
	butt_check()


func _on_h_slider_value_changed(value):
	if value < -30:
		Music.volume_db = value * 2
	else:
		Music.volume_db = value
	
	pass # Replace with function body.
	
func fade_in(delta):

	var fade_mod = $"Black Fade".get_modulate()
	$"Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.03
	print(fade_mod)
	if fade_mod.a <0.1:
		print("DONE")
		set_process(false)

func fade_out(delta):

	var fade_mod = $"Black Fade".get_modulate()
	$"Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.03
	print(fade_mod)
	if fade_mod.a <0.1:
		print("DONE")
		set_process(false)
		

func playcard(card):
	if card.get_node("../..") == $Player1:
		card.reparent($Player1/Playslot,false)
		card.position = Vector2(0,0)
		card.inplay = true
		card.get_child(3).visible = false
		print(card.position)
		print(card.scale)
	else:
		print('not yours')
