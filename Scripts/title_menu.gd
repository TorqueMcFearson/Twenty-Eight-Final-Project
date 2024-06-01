extends Node2D

var fade_goal = Color(1,1,1,0)
var fade_rate = .01
var game_start = false
@onready var main = preload("res://main.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	$"Control/Black Fade".visible = true
	$"Control/Black Fade".modulate = Color(1,1,1,.98)
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fade_mod = $"Control/Black Fade".get_modulate()
	$"Control/Black Fade".set_modulate(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.04
	if fade_mod.a <.1:
		print("DONE")
		set_process(false)
	if fade_mod.a >.99:
		set_process(false)
		if game_start == true:
			$Control/Buttons/New_Game.modulate = Color(0.79, 0.784, 0.427)
			get_tree().change_scene_to_packed(main)
		else:
			print('QUITTED')
			get_tree().quit()

		
	
	



	


func _on_new_game_mouse_entered(extra_arg_0):
	
	$Control/Buttons.get_node_or_null(extra_arg_0).modulate = Color(0.79, 0.784, 0.427)
	pass # Replace with function body.


func _on_mouse_exited(extra_arg_0):
	$Control/Buttons.get_node_or_null(extra_arg_0).modulate = Color(1, 1, 1)
	pass # Replace with function body.


func _on_exit_pressed():
	butts_off()
	$Control/Buttons/New_Game.modulate = Color(0.79, 0.784, 0.427)
	fade_goal = Color(1,1,1,1)
	$"Control/Black Fade".modulate = Color(1,1,1,.12)
	fade_rate = .03
	set_process(true)  
	
func _on_new_game_pressed():
	butts_off()
	$Control/Buttons/New_Game.modulate = Color(0.79, 0.784, 0.427)
	fade_goal = Color(1,1,1,1)
	$"Control/Black Fade".modulate = Color(1,1,1,.12)
	fade_rate = .05
	game_start = true
	set_process(true)
	await Music.fade_out(.75)
	Music.stream = load("res://Assets/SFX & Music/Music/trap-story-SBA-346746122.mp3")
	Music.fade_in(2)
	pass # Replace with function body.

func butts_off():
	for button in $Control/Buttons.get_children():
		button.disabled = true
