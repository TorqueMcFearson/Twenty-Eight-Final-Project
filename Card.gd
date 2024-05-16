extends Node2D

# id, face, suit, rank, value
var id = 0
@export_enum("7", "8", "9", "10", "J", "Q", "K", "A")var face : String
@export_enum("Diamonds", "Spades", "Hearts", "Clubs") var suit : String
@export var rank : int
@export var value : int
@export var face_show : bool
var card_back_img = load("res://Assets/Cards/PNG/Cards/cardBack_red2.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	if face_show:
		face_up()
	else:
		face_down()
	$Label.visible = false
	$Label.text = str((value if value else "No")) + " Point" + ("" if value == 1 else "s")
	if value == 0:
		$Label.modulate = Color(0.513, 0.513, 0.513, 0.99)
	else:
		var hue_adjust = (3-value) * -0.15
		$Label.modulate = Color.from_hsv(0.300+hue_adjust,.9,1)
	pass


func _process(delta):
	#if lifted:
		#global_position = get_global_mouse_position() - offset
	pass
	
func face_toggle():
	if get_child(0).texture == card_back_img:
		face_up()
	else:
		face_down()
		
func face_down():
	get_child(0).texture = card_back_img
	face_show = false
	pass
	
func face_up():
	var cardasssemble = "res://Assets/Cards/PNG/Cards/card" + suit + face + ".png"
	get_child(0).texture = load(cardasssemble)
	face_show = true
	pass

func _on_reference_rect_mouse_entered():
	if face_show:
		$Label.visible = true
	position.y -= 15
func _on_reference_rect_mouse_exited():
	if face_show:
		$Label.visible = false 
	position.y += 15
	

var lifted = false
var offset = 0

####### Was just me testing dragging the cards #####

#func _input_event(viewport, event, shape_idx):
	#pass

#func _on_reference_rect_gui_input(event):
	#if event is InputEventMouseButton and event.pressed and not lifted:
		#offset = get_global_mouse_position() - global_position
		#lifted = true # Replace with function body.
	 #
#func _input(event):
	#if event is InputEventMouseButton and event.pressed and lifted:
		#print('_input recieve')
		#lifted = false
		#get_viewport().set_input_as_handled()
