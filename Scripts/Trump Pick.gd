extends Control

signal trump_picked(which)
var current_bid = 0
var difficulty = 0
#
#
## Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	$"Bet Please/Clubs"
	fade_in()
	pass
#
func fade_in():
	get_tree().create_tween()\
			.tween_property(self,"modulate",Color(1,1,1,1),1)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func fade_out():
		get_tree().create_tween()\
			.tween_property(self,"modulate",Color(1,1,1,0),.45)\
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
			
#


func _on_button_mouse_entered(suit):
	$"Bet Please".get_node(suit).scale = Vector2(.75,.75)

	
	pass # Replace with function body.


func _on_button_mouse_exited(suit):
	$"Bet Please".get_node(suit).scale = Vector2(.625,.625)
	pass # Replace with function body.


func _on_pressed(suit):
	print(suit)
	fade_out()
	emit_signal("trump_picked",suit)
	pass # Replace with function body.
