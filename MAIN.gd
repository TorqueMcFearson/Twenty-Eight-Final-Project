extends Node2D

const MAX_HANDSIZE = 8
 
var drawpile = range(32)
var hand = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print('\nDeck is: \n',drawpile)
	drawpile.shuffle()
	print('\nDrawpile (shuffled) is: \n',drawpile)
	drawto(5)
	drawto(MAX_HANDSIZE)
	for card in hand:
		print('\nHand: ', card.name, " rank: ",card.rank )
	print('\nNew Drawpile: ', drawpile )
	labelupdate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
			
func drawto(amount):
	var drawncards = []
	for each in range(hand.size(),amount):
		var card = Database.database.get(drawpile.pop_front())
		drawncards.append(card)
	for card in drawncards:
		print('\nDrawn cards: ', card.name )
	hand.append_array(drawncards)
	
func labelupdate():
	var labels = [$Hand1/Label, $Hand1/Label2, $Hand1/Label3, $Hand1/Label4, $Hand1/Label5, $Hand1/Label6, $Hand1/Label7, $Hand1/Label8]
	var lranks = [$Hand1/Label/Lrank, $Hand1/Label/Lrank2, $Hand1/Label/Lrank3, $Hand1/Label/Lrank4, $Hand1/Label/Lrank5, $Hand1/Label/Lrank6, $Hand1/Label/Lrank7, $Hand1/Label/Lrank8]
	var lpoints = [$Hand1/Label/Lpoints, $Hand1/Label/Lpoints2, $Hand1/Label/Lpoints3, $Hand1/Label/Lpoints4, $Hand1/Label/Lpoints5, $Hand1/Label/Lpoints6, $Hand1/Label/Lpoints7, $Hand1/Label/Lpoints8]
	var i = 0
	for label in labels:
		label.text = label.text.replace('.',hand[i].face)
		label.text = label.text.replace(',',hand[i].suit)
		i+=1
	i = 0
	for label in lranks:
		label.text = label.text.replace('0',str(hand[i].rank))
		i+=1
	i = 0
	for label in lpoints:
		label.text = label.text.replace('0',str((hand[i].value)))
		i+=1
	var total = 0
	for card in hand:
		total += card.value
	$Hand1/Total.text = $Hand1/Total.text.replace('0',str(total))
	





