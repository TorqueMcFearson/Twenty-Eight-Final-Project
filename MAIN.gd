extends Node2D

const MAX_HANDSIZE = 8
const FACES = ["7", "8", "9", "10", "J", "Q", "K", "A"]
const SUITS = ["♥", "♦", "♣", "♠"]
var deck = []

var drawpile = []
var hand = []

# Called when the node enters the scene tree for the first time.
func _ready():
	deck_construct()
	print('\nDeck is: \n',deck)
	drawpile = deck.duplicate()
	drawpile.shuffle()
	print('\nDrawpile (shuffled) is: \n',drawpile)
	drawto(5)
	drawto(MAX_HANDSIZE)
	print('\nHand: ', hand )
	print('\nNew Drawpile: ', drawpile )
	labelupdate()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func deck_construct():
	for face in FACES:
		for suit in SUITS:
			deck.append(face+suit)
			
func drawto(amount):
	var drawncards = []
	for each in range(hand.size(),amount):
		drawncards.append(drawpile.pop_front())
	print('\nDrawn cards: ', drawncards )
	hand.append_array(drawncards)
	
func labelupdate():
	var labels = [$Hand1/Label, $Hand1/Label2, $Hand1/Label3, $Hand1/Label4, $Hand1/Label5, $Hand1/Label6, $Hand1/Label7, $Hand1/Label8]
	var i = 0
	for label in labels:
		var tempface = hand[i][0]
		if tempface == '1':
			tempface = '10'
		var tempsuit = hand[i][-1]
		label.text = label.text.replace('x',tempface)
		label.text = label.text.replace('y',tempsuit)
		i+=1





