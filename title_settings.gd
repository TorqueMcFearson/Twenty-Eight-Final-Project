extends Control

var paused = false
var music_paused
var title_menu = "res://title_menu.tscn"
var main = "res://main.tscn"
var previous_settings = {}
@onready var easy = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Easy"
@onready var normal = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Normal"
@onready var hard = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Hard"
@onready var regular = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Normal"
@onready var fast = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Fast"
@onready var fastest = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Fastest"
@onready var none = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer5/VBoxContainer/HBoxContainer/None"
@onready var partial = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer5/VBoxContainer/HBoxContainer/Partial"
@onready var full = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer2/VBoxContainer/PanelContainer5/VBoxContainer/HBoxContainer/Full"
@onready var volume_node = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer/VBoxContainer"
@onready var master = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer/VBoxContainer/Master Volume/VBoxContainer/Master"
@onready var music = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer/VBoxContainer/Music Volume/VBoxContainer/Music"
@onready var sfx = $"Game Settings Node/PanelContainer2/Game Settings Box/PanelContainer/VBoxContainer/SFX Volume/VBoxContainer/Sfx"


@onready var difficulty_group = [easy,normal,hard]
@onready var guide_group = [none,partial,full]
@onready var speed_group = [regular,fast,fastest]


# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for each in ['Master','Music','Sfx']:
		var volume = 100+(AudioServer.get_bus_volume_db(i)*2)
		volume_node.find_child(each).value = volume
		previous_settings[each] = volume
		i +=1
	for each in ['difficulty','game_speed','guides']:
		previous_settings[each] = Global.get(each)
	difficulty_group[Global.difficulty].set_pressed(true)
	speed_group[((Global.game_speed-1)*2)].set_pressed(true)
	guide_group[Global.guides].set_pressed(true)
	print(previous_settings)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		pause_game()



func pause_game():
	var dark = $"Pause Fade"
	var pause_menu = $"."
	if not paused:
		music_paused = Music.stream_paused
		Music.stream_paused = true
		dark.visible = true
		pause_menu.visible = true
		#Engine.time_scale = 0
		get_tree().paused = true
		visible = true

	else:
		Music.stream_paused = music_paused
		dark.visible = false
		#Engine.time_scale = 1
		get_tree().paused = false
		visible = false
		print('resumed')
	paused = !paused
	
################################ PAUSE MENU AREA ################################
func _on_resume_game_pressed():
	pause_game()
	
	
func _on_restart_game_pressed():
	pause_game()
	get_tree().reload_current_scene()


func _on_return_to_title_pressed():
	pause_game()
	get_tree().change_scene_to_packed(load(title_menu))


func _on_quit_to_desktop_pressed():
	get_tree().quit()


func _on_game_options_pressed():
	for each in [master,music,sfx]:
		each.ready_up()
	create_tween().tween_property($"Pause Node","position",Vector2(-914,0),.30).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	create_tween().tween_property($"Game Settings Node","position",Vector2(-914,0),.38).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(.20)
	pass # Replace with function body.

################################ GAME OPTIONS AREA ################################


func _on_cancel_pressed():
	create_tween().tween_property($"Game Settings Node","position",Vector2(0,0),.30).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	create_tween().tween_property($"Pause Node","position",Vector2(0,0),.38).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(.20) # Replace with function body.


func _on_ready_pressed():
	create_tween().tween_property($"Game Settings Node","position",Vector2(0,0),.30).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	create_tween().tween_property($"Pause Node","position",Vector2(0,0),.38).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(.20) # Replace with function body.
