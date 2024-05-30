extends Node2D
@onready var Director = $"/root/Director"
@onready var click_delay = $"/root/Director/Click Delay"
#signal 



var id: int					# Unique Id for database lookup
@export_enum("7", "8", "9", "10", "J", "Q", "K", "A") var face : String
@export_enum("Diamonds", "Spades", "Hearts", "Clubs") var suit : String
## PROPERTIES FROM DATABASE ARE -- id, face, suit, rank, value
var rank : int				# Its order in which cards it win/lose over.
var value : int				# It's point value in trick scoring
var face_show : bool		# Wether is currently face up or down.
var inplay := false			# Wether is currently in the play slot.
var tweening := false		# Wether is currently animating.
var card_back_img = preload("res://Assets/Cards/PNG/Cards/cardBack_red2.png")
var slot := Vector2(0,0)
var trump := false
var disabled := true
var selected := false


# Called when the node enters the scene tree for the first time.
func _ready():
	if face_show:
		face_up()
	else:
		face_down()
	$Label.visible = false
	$Label.text = (str(value) if value else "No") + " Point" + ("" if value == 1 else "s")
	if value == 0:
		$Label.modulate = Color(0.513, 0.513, 0.513, 0.99)
	else:
		var hue_adjust = (3-value) * -0.15
		$Label.modulate = Color.from_hsv(0.300+hue_adjust,.9,1)
	$Label2.text = str(rank)


func _process(_delta):
	
	#if lifted:
		#global_position = get_global_mouse_position() - offset
	pass
	
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if Global.cards_playable and not tweening and selected:
			deselect_and_go()
			
				
func grow_and_go():
	tweening = true
	scale = Vector2(0,0)
	var tween = create_tween()
	tween.finished.connect(_tween_end)
	tween.tween_property(self,'scale',Vector2(1,1),.35).set_ease(Tween.EASE_IN)
	
	# NOTE: As seen below, '\' lets you put continuous code on the next line. 
	# WARNING: Don't accidentaly add space after! '\ '
	var tween2 = create_tween()
	tween2.tween_property(self,'position',slot,.5)\
			.set_ease(Tween.EASE_IN_OUT)\
			.set_trans(Tween.TRANS_BACK)

func select_and_go():
	selected = true
	tweening = true
	get_tree().create_tween().tween_property(get_node("shadow"),"position",Vector2(-22,22),.20)
	#var tween = get_tree().create_tween()
	#tween.tween_property(self,'scale',Vector2(1.25,1.25),.20).set_trans(Tween.TRANS_ELASTIC)
	var tween2 = get_tree().create_tween()
	tween2.finished.connect(_tween_end)
	tween2.tween_property(self,'position',slot,.20).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)


func deselect_and_go():	
	selected = false
	get_tree().create_tween().tween_property(get_node("shadow"),"position",Vector2(-6,3),.20)
	Director.take_card(self)

func go():

	tweening = true
	var tween = create_tween()

	tween.tween_property(self,'scale',Vector2(1,1),.10).set_trans(Tween.TRANS_ELASTIC)
	var tween2 = create_tween()
	tween2.tween_property(self,'position',slot,.35).set_ease(Tween.EASE_IN).set_trans(tween.TRANS_BACK)
	tween2.finished.connect(_tween_end)
	await tween2.finished

func go_and_die():
	tweening = true
	get_tree().create_tween().tween_property(self,'global_rotation',0,.45)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).finished
			
	await get_tree().create_tween().tween_property(self,'global_position',Vector2(531,237),.45)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC).finished
			
	var tween = create_tween()
	tween.finished.connect(_tween_end)
	tween.tween_property(self,'scale',Vector2(.25,.25),1).set_trans(Tween.TRANS_ELASTIC)
	
	var tween2 = create_tween()
	tween2.tween_property(self,'global_position',slot,.56).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tween2.finished
	get_parent().remove_child(self)
	queue_free()
	
func go_and_redeal():
	tweening = true
	var tween = create_tween()
	tween.finished.connect(_tween_end)
	tween.tween_property(self,'scale',Vector2(.25,.25),1).set_trans(Tween.TRANS_ELASTIC)
	
	var tween2 = create_tween()
	tween2.tween_property(self,'global_position',Vector2(1101,490),.56).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tween2.finished
	get_parent().remove_child(self)
	queue_free()
	
	
func _tween_end():
	tweening = false
	
func face_toggle():
	if get_child(0).texture == card_back_img:
		face_up()
	else:
		face_down()
		
func face_down():
	get_node("CardBack").texture = card_back_img
	face_show = false
	pass
	
func face_up():
	var cardasssemble = "res://Assets/Cards/PNG/Cards/card" + suit + face + ".png"
	get_node("CardBack").texture = load(cardasssemble)
	face_show = true
	
	pass
	
	
func trump_check():
	if suit == Director.trump_suit and Director.trump_revealed:
		if face_up:
			$CardBack.set_self_modulate(Color(0.88300001621246, 1, 0.87000000476837))
			$CardBack/Panel.visible = false
		if rank <99:
			rank +=100
		trump = true
		return trump
		
func _on_reference_rect_mouse_entered():
	if not tweening and not selected:
		if face_show:
			$Label.visible = true
			if trump:
				$"Trump Label".visible = true
				$CardBack.set_self_modulate(Color(0.78400003910065, 1, 0.75999999046326))
				$CardBack/Panel.visible = true
		if not inplay and not selected:
			if disabled and face_show:
				position.y = -10
			else:
				position.y = -20
		
func _on_reference_rect_mouse_exited():
	if not tweening and not selected:
		if face_show:
			$Label.visible = false
			if trump:
				$"Trump Label".visible = false
				$CardBack.set_self_modulate(Color(0.88300001621246, 1, 0.87000000476837))
				$CardBack/Panel.visible = false
		if not inplay and not selected:
			position.y = 0
	



func _on_reference_rect_gui_input(event): # A click event
	if Global.cards_playable and not tweening and not disabled and $"../..".human and not click_delay.get_time_left():
		if event is InputEventMouseButton and event.pressed:
			if not inplay and not selected:
				Director.select_card(self)
				click_delay.start(.5)
				$Label.visible = true
				if trump:
					$"Trump Label".visible = true
					$CardBack.set_self_modulate(Color(0.78400003910065, 1, 0.75999999046326))
					$CardBack/Panel.visible = true
			elif selected and not tweening:
				Director.play_card(self)
				$Label.visible = false
				if trump:
					$"Trump Label".visible = false
					$CardBack.set_self_modulate(Color(0.88300001621246, 1, 0.87000000476837))
					$CardBack/Panel.visible = false
				z_index -=2
				inplay = true
				click_delay.start(.5)


func enable_card():
	disabled = false
	modulate = Color(1,1,1)
	
func disable_card():
	disabled = true
	if face_show:
		modulate = Color(0.80, 0.80, 0.80)
	
func label_off():
		$Label.visible = false
		if trump:
			$"Trump Label".visible = false
			$CardBack.set_self_modulate(Color(0.88300001621246, 1, 0.87000000476837))
			$CardBack/Panel.visible = false

