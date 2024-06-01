extends Control

const DEFAULT = "Twenty-Eight has many different rules. Customize the ones you are fimilar with or would like to try. These cannot be changed during the match."
const american = "[b]Filthy American Mode[/b]
This changes the order of value and rank of each card to resemble something that is more fimilar in american card games.
[font_size=18]
[color=green]ON[/color] - Cards ranked low-to-high as 7, 8, 9, 10, J, Q, K, A
[color=orange]OFF[/color] - Cards ranked low-to-high as 7, 8, Q, K, 10, A, 9, J[/font_size]
[center][u]

[font_size=22][color=red]For a traditional experience, this mode is not recommened.[/color][/font_size][/u][/center]"
const partner_bid = "[b]Partner Overbid Minimum[/b] 
Sets the minimum bid rule for bidding over your partner if they were the last to bid.

[color=green]ON[/color] - minimum of 20.
[color=orange]OFF[/color] - no minimum"
const bet_pips = "[b]Bet Based Scoring[/b]
This rule changes how many pips [i](match points)[/i] are won based on the winning team’s bid.

[u]The bids are as follows:[/u]
[ul][b]14 to 19:[/b] Win [color=green]+1 pip[/color] or Lose [color=orange]-2 pips[/color].
[b]20 to 24:[/b] Win [color=green]+2 pip[/color] or Lose [color=orange]-3 pips[/color].
[b]25 to 28:[/b] Win [color=green]+3 pip[/color] or Lose [color=orange]-4 pips[/color].[/ul]

[color=green]ON[/color] - Pips scoring uses the bet-based pip system.
[color=orange]OFF[/color] - Pip scoring uses a standard 1-pip system"
const final_bet = "[b]Post-Trump Bid[/b]
This rule allows the bid winning team a final chance to increase their bid to 24, after everyone has been dealt eight cards. Must include the [b]Bet Based Pips[/b] to make sense.

[color=green]ON[/color] - The final bid is allowed.
[color=orange]OFF[/color] - The final bid is not allowed."
const redeal = "[b]First-Hand Redeal[/b]
This rule goes into effect when openning bidder's first 4 cards have no point values, at which point only they may request redeal of everyone's cards.

[color=green]ON[/color] - The redeal rule is allowed.
[color=orange]OFF[/color] - The redeal rule is not allowed."
const difficulty = "[b]AI Difficulty[/b]
This mainly determines how aggressive the AI is with it's bidding and how likely it is to make mistakes."
const speed = "[b]Game Speed[/b]
This setting will determine the speed of the game engine, affecting animations and wait times."

enum {AMERICAN,PARTNER_BID,FINAL_BET,BET_PIPS,REDEAL,DIFFICULTY,SPEED}
# Called when the node enters the scene tree for the first time.
@onready var american_button = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/American"
@onready var traditional_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Traditional Rules"
@onready var partner_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Partner Overbid"
@onready var final_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Final Bet"
@onready var pips_button = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Bet Based Pips"
@onready var redeal_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Redeal"
@onready var easy = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Easy"
@onready var normal = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Normal"
@onready var hard = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Hard"
@onready var medium = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Normal"
@onready var fast = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Fast"
@onready var fastest = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Fastest"

@onready var button_group = [pips_button,final_button,partner_button,redeal_button]
@onready var difficulty_group = [easy,normal,hard]
@onready var speed_group = [medium,fast,fastest]

func _ready():
	position = Vector2(0,-600)
	modulate = Color(1,1,1,0)
	$Card_PopUp.play()
	var tween = create_tween()
	tween.tween_property(self,"position",Vector2(0,0),0.42).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	var tween2 = get_tree().create_tween().tween_property(self,"modulate", Color(1,1,1,1),.42).set_ease(Tween.EASE_IN)
	var rules = ["bet_based_pips","final_bet","partner_bid","redeal"]
	var i = 0
	traditional_button.set_pressed(Global.variant_rules.traditional)
	for each in button_group:
		each.set_pressed(Global.variant_rules[rules[i]])
		i+=1
	difficulty_group[Global.difficulty].set_pressed(true)
	speed_group[((Global.game_speed-1)*2)].set_pressed(true)


func _rule_hover(rule):
	match rule:
		AMERICAN:
			$"Margin Container/PanelContainer3/Rule Text".text = american
		PARTNER_BID:
			$"Margin Container/PanelContainer3/Rule Text".text = partner_bid
		FINAL_BET:
			$"Margin Container/PanelContainer3/Rule Text".text = final_bet
		BET_PIPS:
			$"Margin Container/PanelContainer3/Rule Text".text = bet_pips
		REDEAL:
			$"Margin Container/PanelContainer3/Rule Text".text = redeal
		DIFFICULTY:
			$"Margin Container/PanelContainer3/Rule Text".text = difficulty
		SPEED:
			$"Margin Container/PanelContainer3/Rule Text".text = speed
		-1:
			$"Margin Container/PanelContainer3/Rule Text".text = DEFAULT
	if rule == DIFFICULTY:
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/Label".modulate = Color(0.85098040103912, 0.53333336114883, 0.16862745583057)
	if rule == SPEED:
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/Label".modulate = Color(0.85000002384186, 0.53266668319702, 0.17000000178814)
	pass # Replace with function body.

func _rule_hover_exit(rule):
		$"Margin Container/PanelContainer3/Rule Text".text = ""
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/Label".modulate = Color(1,1,1)
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/Label".modulate = Color(1,1,1)


func _on_cancel_ready_entered(node):
	get_node_or_null(node).modulate = Color(1, 0.60, 0.14, 0.733)
	pass # Replace with function body.

func _on_cancel_ready_exited(node):
	get_node_or_null(node).modulate = Color(1, 1, 1,0.733)
	pass # Replace with function body.

func _on_checkbutton_toggled(toggled_on, rule):
	Global.variant_rules[rule] = true if toggled_on else false
	print(rule,': ',Global.variant_rules[rule])
	if rule == "bet_based_pips":
		final_button.disabled = !toggled_on
		final_button.set_pressed(false)
	pass # Replace with function body.


func _on_traditional_rules_toggled(toggled_on):
	print("Traditional Button Fired")
	for each in button_group:
		each.disabled = !toggled_on
		each.set_pressed(false)
	final_button.disabled = true
	Global.variant_rules.traditional = toggled_on
	#for each in Global.variant_rules.keys():
		#Global.variant_rules[each] = false
		#print(Global.variant_rules[each])


func _on_difficulty_button(value):
	Global.difficulty = value # Replace with function body.


func _on_game_speed(speed):
	Global.game_speed = speed
	pass # Replace with function body.


func _on_ready_pressed():
	$Ready.modulate = Color(0.01176469959319, 0.57254898548126, 1, 0.77254897356033)
	$Card_PopUp.play()
	var tween = create_tween()
	tween.tween_property(self,"position",Vector2(0,-600),0.42).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	var tween2 = create_tween().tween_property(self,"modulate", Color(1,1,1,0.12),.42).set_ease(Tween.EASE_IN)
	$/root/Director.emit_signal("move_on")
	tween.tween_callback(self.queue_free)
	
	pass # Replace with function body.pass # Replace with function body.

func butt_off():
	$Ready.disabled = true
	$Cancel.disabled = true


func _on_cancel_pressed():
	get_tree().change_scene_to_packed(load("res://title_menu.tscn"))
	pass # Replace with function body.
