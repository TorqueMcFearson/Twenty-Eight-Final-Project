extends Node2D

# id, face, suit, rank, value
var id = 0
@export_enum("7", "8", "9", "10", "J", "Q", "K", "A")var face : String
@export_enum("Diamonds", "Spades", "Hearts", "Clubs") var suit : String
@export var rank : int
@export var value : int
@export var face_show : bool
var inplay = false
var tweening = false
var card_back_img = load("res://Assets/Cards/PNG/Cards/cardBack_red2.png")
var slot = Vector2(0,0)


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
	
func grow_and_go(to_hand):
	tweening = true
	scale = Vector2(0,0)
	var tween = create_tween()
	tween.finished.connect(_tween_end)
	tween.tween_property(self,'scale',Vector2(1,1),.25)
	var tween2 = create_tween()
	tween2.tween_property(self,'position',slot,.25)

func go():
	tweening = true
	var tween = create_tween()
	tween.finished.connect(_tween_end)
	tween.tween_property(self,'scale',Vector2(1,1),.25)
	var tween2 = create_tween()
	tween2.tween_property(self,'position',slot,.25)


	
	
func _tween_end():
	tweening = false
	print(self, 'tween done')
	
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
	if not inplay and not tweening:
		if face_show :
			$Label.visible = true
		position.y = -15
func _on_reference_rect_mouse_exited():
	if not inplay and not tweening:
		if face_show:
			$Label.visible = false 
		position.y = 0
	

#var lifted = false
#var offset = 0

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


func _on_reference_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and not tweening:
		if inplay == false:
			get_node('/root/Director').playcard(self)
		else:
			get_node('/root/Director').take_card(self)
		
	pass # Replace with function body.
