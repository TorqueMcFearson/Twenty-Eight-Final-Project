extends Node2D

# id, face, suit, rank, value 
var id = 0
@export_enum("7", "8", "9", "10", "J", "Q", "K", "A")var face : String
@export_enum("Diamonds", "Spades", "Hearts", "Clubs") var suit : String
@export var rank : int
@export var value : int



# Called when the node enters the scene tree for the first time.
func _ready():
	var cardasssemble = "res://Assets/Cards/PNG/Cards/card" + suit + face + ".png"
	get_child(0).texture = load(cardasssemble)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.

func update_texture():
	pass
	
func _process(delta):
	pass
