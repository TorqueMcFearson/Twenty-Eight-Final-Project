extends Node

# Preload card template, so it doesn't have to load every time function called:
var cardbase = preload("res://cardbase.tscn") 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# NOTE: PROPERTIES FROM DATABASE ARE -- [id, face, suit, rank, value]
# Function creates new card from IDs in the Draw Deck. 
# Pass-through arguements are the card ID and whether to be face up or down.
func newcard(id,face_show):
	if id == null:  						# Redudnacy Error check
		print("NULL encountered on newcard() in Card Constructor")
		return
	var new_card = cardbase.instantiate() 	# Unpack Scene into a ready node.
	var props = Database.cards.get(id)  	# Uses ID to retrieve cards props from the database
	for prop in props:						# Applies each property to the card in a for loop
		new_card[prop] = props[prop]
	new_card.face_show = face_show  		# Applies face_show up or down from the pass-through.
	return new_card 						# Sends the card to the Director.
	
