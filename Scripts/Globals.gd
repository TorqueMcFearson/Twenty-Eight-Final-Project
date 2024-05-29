extends Node
# id, face, suit, rank, value
const FACES = ["7", "8", "Q", "K", "10", "A", "9", "J"] # Arranged from lowest rank to highest
const SUITS = ["Diamonds", "Spades", "Hearts", "Clubs"] # 
const POINTS = {'J':3,'9':2, 'A':1, '10':1} #Dictionary for lookup point value. Returns for J,9,A,10
var cards = {} # Declare array, for use in functions
enum {BABYMODE, EASY, NORMAL, HARD}
##---------Global Variables---------##
var cards_playable = false
var difficulty = BABYMODE

func database_constructor(x):
	#var id = 0 # Unique Id for every suit/face
	#var rank = 0 # Rising rank value for every face.
	#for face in FACES:
		#rank += 1
		#for suit in SUITS:
			## id, Face, Suit, Rank, value 
			#x[id] = {
				#'id': id, 
				#'face':face, 
				#'suit':suit,
				#'rank':rank,
				#'value':POINTS.get(face,0)} # Searches POINTS with face, returns value if found 0 is default. 
			#id +=1
	var id = 0 # Unique Id for every suit/face
	var rank = 0 # Rising rank value for every face.
	for suit in SUITS:
		rank = 0
		for face in FACES:
			# id, Face, Suit, Rank, value 
			rank += 1
			x[id] = {
				'id': id, 
				'face':face, 
				'suit':suit,
				'rank':rank,
				'value':POINTS.get(face,0)} # Searches POINTS with face, returns value if found 0 is default. 
			id +=1



# Called when the node enters the scene tree for the first time.
func _ready():
	database_constructor(cards)


