extends Node
# id, face, suit, rank, value
const FACES = ["7", "8", "Q", "K", "10", "A", "9", "J"] # Arranged from lowest rank to highest
const AMERICAN_FACES = ["7", "8", "9", "10", "J", "Q", "K", "A"]
const SUITS = ["Diamonds", "Spades", "Hearts", "Clubs"] # 
const POINTS = {'J':3,'9':2, 'A':1, '10':1} #Dictionary for lookup point value. Returns for J,9,A,10
const AMERICAN_POINTS = {'A':3,'K':2, 'Q':1, 'J':1} #Dictionary for lookup point value. Returns for J,9,A,10
var cards = {} # Declare array, for use in functions
enum {EASY, NORMAL, HARD}
##---------Global Variables---------##
var cards_playable = false
var game_speed : float = 1
var difficulty = NORMAL
var variant_rules : Dictionary = {
"traditional" : true, 
"partner_bid": true, 
"final_bet": true, 
"bet_based_pips": true, 
"redeal":true, 
"american_mode" : false}


func database_constructor(x):
	if not variant_rules.american_mode:
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
	else:
		var id = 0 # Unique Id for every suit/face
		var rank = 0 # Rising rank value for every face.
		for suit in SUITS:
			rank = 0
			for face in AMERICAN_FACES:
				# id, Face, Suit, Rank, value 
				rank += 1
				x[id] = {
					'id': id, 
					'face':face, 
					'suit':suit,
					'rank':rank,
					'value':AMERICAN_POINTS.get(face,0)} # Searches POINTS with face, returns value if found 0 is default. 
				id +=1

# Called when the node enters the scene tree for the first time.
func _ready():
	database_constructor(cards)


