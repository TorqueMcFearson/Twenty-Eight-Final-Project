extends Node

var cardbase = preload("res://cardbase.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func newcard(id):
	if id == null:
		print("NULL encountered on newcard() in Card Constructor")
		return
	var new_card = cardbase.instantiate()
	var props = Database.cards.get(id)

	for prop in props:
		new_card[prop] = props[prop]
	return new_card
	
