extends Node2D

const MAX_HANDSIZE = 8
 
var drawpile = range(1)
var discardpile = []
var hand = []
var testhand = []

# Called when the node enters the scene tree for the first time.
func _ready():
	$Discard_Deck.visible = false
	$DrawDeck/Amount.text = str(drawpile.size())
	print('\nDeck is: \n',drawpile)
	drawpile.shuffle()
	print('\nDrawpile (shuffled) is: \n',drawpile)
	for card in hand:
		print('\nHand: ', card.face, " rank: ",card.rank )
	print('\nNew Drawpile: ', drawpile )
	#labelupdate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func drawto(amount):
	var drawncards = []
	for each in range(hand.size(),amount):
		var card = Database.cards.get(drawpile.pop_front())
		drawncards.append(card)
	hand.append_array(drawncards)

#func labelupdate():
	#var labels = [$Hand1/Label, $Hand1/Label2, $Hand1/Label3, $Hand1/Label4, $Hand1/Label5, $Hand1/Label6, $Hand1/Label7, $Hand1/Label8]
	#var lranks = [$Hand1/Label/Lrank, $Hand1/Label/Lrank2, $Hand1/Label/Lrank3, $Hand1/Label/Lrank4, $Hand1/Label/Lrank5, $Hand1/Label/Lrank6, $Hand1/Label/Lrank7, $Hand1/Label/Lrank8]
	#var lpoints = [$Hand1/Label/Lpoints, $Hand1/Label/Lpoints2, $Hand1/Label/Lpoints3, $Hand1/Label/Lpoints4, $Hand1/Label/Lpoints5, $Hand1/Label/Lpoints6, $Hand1/Label/Lpoints7, $Hand1/Label/Lpoints8]
	#var i = 0
	#for label in labels:
		#label.text = label.text.replace('.',hand[i].face)
		#label.text = label.text.replace(',',hand[i].suit)
		#i+=1
	#i = 0
	#for label in lranks:
		#label.text = label.text.replace('0',str(hand[i].rank))
		#i+=1
	#i = 0
	#for label in lpoints:
		#label.text = label.text.replace('0',str((hand[i].value)))
		#i+=1
	#var total = 0
	#for card in hand:
		#total += card.value
	#$Hand1/Total.text = $Hand1/Total.text.replace('0',str(total))

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
		print('empty hand')
		return
	var node = $Player1/Hand
	print('node: ', node)
	for n in node.get_children():
		var card = n.get('id')
		discardpile.append(card)
		print('removing: ',card)
		node.remove_child(n)
		n.queue_free()
	print(discardpile)
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
	print("Time taken: ",sum)
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
	
