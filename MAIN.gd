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
	print('Deck is: \n',deck)
	drawpile = deck.duplicate()
	drawpile.shuffle()
	print('Drawpile (shuffled) is: \n',drawpile)
	var drawncard = drawpile.pop_back()
	hand.append(drawncard)
	print('Drawn card: ', drawncard )
	print('Hand: ', hand )
	print('New Drawpile: ', drawpile )
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func deck_construct():
	for face in FACES:
		for suit in SUITS:
			deck.append(face+suit)
