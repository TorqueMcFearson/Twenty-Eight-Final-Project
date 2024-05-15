extends Node

const FACES = ["7", "8", "Q", "K", "10", "A", "9", "J"] # Arranged from lowest rank to highest
const SUITS = ["♥", "♦", "♣", "♠"] # I guess it's okay to use Unicode in strings apparently.
const POINTS = {'J':3,'9':2, 'A':1, '10':1} #Dictionary for lookup point value.
var database = {} # Declare array, for use in functions

func datebase_constructor(x):
	var id = 0
	var rank = 0
	for face in FACES:
		rank += 1
		for suit in SUITS:
			# Name, Face, Suit, Rank, value 
			x[id] = {'name':face+suit, 'face':face, 'suit':suit,'rank':rank,'value':POINTS.get(face,0)}
			id +=1



# Called when the node enters the scene tree for the first time.
func _ready():
	datebase_constructor(database)
	for x in database:
		print(x," : ", database[x]) # Replace with function body.
	var testid = 25
	var testcard = database.get(testid)
	print(testcard)
