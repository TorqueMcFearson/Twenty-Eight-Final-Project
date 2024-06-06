extends Node2D

var fade_goal = Color(1,1,1,1)
var fade_rate = .01
var game_start = false 
@onready var black_fade = $Control/black_fade

const MAIN = preload("res://main.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	#black_fade.modulate = Color(1,1,1,.98)
	Music.stream = Music.TITLE_MUSIC
	Music.fade_in(1)
	print(get_tree().current_scene)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var fade_mod = black_fade.get_color()
	black_fade.set_color(lerp(fade_mod, fade_goal, fade_rate*delta))
	fade_rate+=0.04
	if fade_mod.r >.99:
		print("DONE")
		set_process(false)
	if fade_mod.r <.01:
		set_process(false)
		if game_start == true:
			$Control/Buttons/New_Game.modulate = Color(0.79, 0.784, 0.427)

			get_tree().change_scene_to_packed(MAIN)
		else:
			print('QUITTED')
			get_tree().quit()

func _on_new_game_mouse_entered(extra_arg_0):
	$Control/Buttons.get_node_or_null(extra_arg_0).modulate = Color(0.79, 0.784, 0.427)
	pass # Replace with function body.


func _on_mouse_exited(extra_arg_0):
	$Control/Buttons.get_node_or_null(extra_arg_0).modulate = Color(1, 1, 1,)
	pass # Replace with function body.


func _on_exit_pressed():
	butts_off()
	$Control/Buttons/New_Game.modulate = Color(0.79, 0.784, 0.427)
	fade_goal = Color(1,1,1,1)
	black_fade.color = Color(1,1,1,.12)
	fade_rate = .03
	set_process(true)  
	
func _on_new_game_pressed():
	butts_off()
	$Control/Buttons/New_Game.modulate = Color(0.79, 0.784, 0.427)
	fade_goal = Color(0,0,0,1)
	black_fade.color = Color(.98,.98,.98,1)
	fade_rate = .05
	game_start = true
	set_process(true)
	await Music.fade_out(.75)
	Music.stream = Music.GAME_MUSIC
	Music.fade_in(2)
	pass # Replace with function body.

func butts_off():
	for button in $Control/Buttons.get_children():
		button.disabled = true


func _on_setting_pressed():
	$"CanvasLayer/Pause Menu".visible = true
	$"CanvasLayer/Pause Menu/Pause Node".visible = false
	$"CanvasLayer/Pause Menu"._on_game_options_pressed()
	pass # Replace with function body.
