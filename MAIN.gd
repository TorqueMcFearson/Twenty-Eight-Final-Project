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
	
		
