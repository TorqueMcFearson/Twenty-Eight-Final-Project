extends Control
const title_menu = preload("res://title_menu.tscn")

const DEFAULT = "[color=#d9882b][font_size=17][b]Customize Rules[/b][/font_size][/color]
Twenty-Eight has many different houses rules. So customize the ones you are fimilar with or would like to try. Choose carefully as these cannot be changed during the match."


const american = "[color=#d9882b][font_size=17][b]Filthy American Mode[/b][/font_size][/color]
This reorganizes the value and rank of each card to resemble something that is more fimilar in american card games.
[font_size=17]
American ranks: 7-8-9-10-J-Q-K-A
Traditional ranks: 7-8-Q-K-10-A-9-J[/font_size]
[font_size=15]

[/font_size]
[center][u][font_size=16][color=red]For a traditional experience, this mode is not recommened.[/color][/font_size][/u][/center]"


const partner_bid = "[color=#d9882b][font_size=17][b]Partner Bid Minimum[/b][/font_size][/color]
Sets the minimum bid rule for bidding over your partner if they were the last to bid.
"
#[color=green]ON[/color] - minimum of 20.
#[color=red]OFF[/color] - no minimum"


const bet_pips = "[color=#d9882b][font_size=17][b]Bid-Based Scoring[/b][/font_size][/color]
This rule changes how many pips (match points) are won based on the winning team’s bid from the standard 1 pip win/loss.
[font_size=17]
[ul][b]14 to 19:[/b] Win [color=green]+1 pip[/color] or Lose [color=red]-2 pips[/color].
[b]20 to 24:[/b] Win [color=green]+2 pip[/color] or Lose [color=red]-3 pips[/color].
[b]25 to 28:[/b] Win [color=green]+3 pip[/color] or Lose [color=red]-4 pips[/color].[/ul]
"
#[color=green]ON[/color] - Pips scoring uses the bet-based pip system.
#[color=red]OFF[/color] - Pip scoring uses a standard 1-pip system[/font_size]"


const final_bet = "[color=#d9882b][font_size=17][b]Post-Trump Bid[/b][/font_size][/color]
This rule allows the bid winning team a final chance to increase their bid to 24, after everyone has been dealt eight cards. Must include the [b]Bet Based Pips[/b] to make sense.
"
#[color=green]ON[/color] - The final bid is allowed.
#[color=red]OFF[/color] - The final bid is not allowed."


const redeal = "[color=#d9882b][font_size=17][b]First-Hand Redeal[/b][/font_size][/color]
This rule goes into effect when openning bidder's first 4 cards have no point values, at which point only they may request redeal of everyone's cards."

#[color=green]ON[/color] - The redeal rule is allowed.
#[color=red]OFF[/color] - The redeal rule is not allowed."


const difficulty = "[color=#d9882b][font_size=17][b]AI Difficulty[/b][/font_size][/color]
This mainly determines how aggressive the AI is with it's bidding and how likely it is to make mistakes."


const speed = "[color=#d9882b][font_size=17][b]Game Speed[/b][/font_size][/color]
This setting will determine the speed of the game engine, affecting animations and wait times."

const guides = "[color=#d9882b][font_size=17][b]Guides/Highlights[/b][/font_size][/color]
This option chooses the level of contextual highlights and remainders for trumps, playsuit, bids, points and more.
[font_size=17]
[color=red]None[/color] - Cardtable experience, no tooltips or highlights.
[color=orange]Partial[/color] - Limited contextual text and tooltip information.
[color=green]Full[/color] - Game experience Full card highlighting and tooltips[/font_size]"

const pair = "[color=#d9882b][font_size=17][b]Trump Pair[/b][/font_size][/color]
This rule applies when a player has both the king and queen that matches the trump suit. It occurs at the end of the round that the trump was revealed in. If the player with the pair is on the bidding team, the bid is lowered by 4 points, otherwise the bid is raised by 4 points.
[font_size=17]
[color=red]None[/color] - Cardtable experience, no tooltips or highlights.
[color=orange]Partial[/color] - Limited contextual text and tooltip information.
[color=green]Full[/color] - Game experience Full card highlighting and tooltips[/font_size]"

enum {AMERICAN,PARTNER_BID,FINAL_BET,BET_PIPS,REDEAL,DIFFICULTY,SPEED,GUIDES,PAIR}
# Called when the node enters the scene tree for the first time.
@onready var american_button = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/American"
@onready var traditional_button = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Traditional Rules"
@onready var partner_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Partner Overbid"
@onready var final_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Final Bet"
@onready var pips_button = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Bet Based Pips"
@onready var redeal_button =$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Redeal"
@onready var trump_pair = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/VBoxContainer/Trump Pair"
@onready var easy = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Easy"
@onready var normal = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Normal"
@onready var hard = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Hard"
@onready var medium = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Normal"
@onready var fast = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Fast"
@onready var fastest = $"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/HBoxContainer/Fastest"
@onready var none = $PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/None
@onready var partial = $PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Partial
@onready var full = $PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/HBoxContainer/Full

@onready var button_group = [partner_button,pips_button,final_button,redeal_button,trump_pair]
@onready var difficulty_group = [easy,normal,hard]
@onready var guide_group = [none,partial,full]
@onready var speed_group = [medium,fast,fastest]

func _ready():
	position = Vector2(0,-600)
	modulate = Color(1,1,1,0)
	$Card_PopUp.play()
	var tween = create_tween()
	tween.tween_property(self,"position",Vector2(0,0),0.42).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	get_tree().create_tween().tween_property(self,"modulate", Color(1,1,1,1),.42).set_ease(Tween.EASE_IN)
	init_rules()
	init_options()


func init_rules():
	var rules = ["partner_bid","bet_based_pips","final_bet","redeal","pair"]
	var i = 0
	traditional_button.set_pressed(Global.variant_rules.traditional)
	american_button.set_pressed_no_signal(Global.variant_rules.american)
	for each in button_group:
		if Global.variant_rules.traditional:
			each.disabled = false
		each.set_pressed_no_signal(Global.variant_rules[rules[i]])
		i+=1
	
	
func init_options():
	print("Option Init")
	difficulty_group[Global.difficulty].set_pressed(true)
	print(difficulty_group[Global.difficulty].is_pressed())
	speed_group[((Global.game_speed-1)*2)].set_pressed(true)
	guide_group[Global.guides].set_pressed(true)


func _rule_hover(rule):
	match rule:
		AMERICAN: #0
			$"Margin Container/PanelContainer3/Rule Text".text = american
		PARTNER_BID:#1
			$"Margin Container/PanelContainer3/Rule Text".text = partner_bid
		FINAL_BET:#2
			$"Margin Container/PanelContainer3/Rule Text".text = final_bet
		BET_PIPS: #3
			$"Margin Container/PanelContainer3/Rule Text".text = bet_pips
		REDEAL:#4
			$"Margin Container/PanelContainer3/Rule Text".text = redeal
		DIFFICULTY:#5
			$"Margin Container/PanelContainer3/Rule Text".text = difficulty
		SPEED:#6
			$"Margin Container/PanelContainer3/Rule Text".text = speed
		GUIDES:#7
			$"Margin Container/PanelContainer3/Rule Text".text = guides
		PAIR:#8
			$"Margin Container/PanelContainer3/Rule Text".text = pair
		-1:
			$"Margin Container/PanelContainer3/Rule Text".text = DEFAULT
	if rule == DIFFICULTY:
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/Label".modulate = Color(0.85098040103912, 0.53333336114883, 0.16862745583057)
	if rule == SPEED:
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/Label".modulate = Color(0.85000002384186, 0.53266668319702, 0.17000000178814)
	pass # Replace with function body.

func _rule_hover_exit(_rule):
		#$"Margin Container/PanelContainer3/Rule Text".text = ""
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer3/VBoxContainer/Label".modulate = Color(1,1,1)
		$"Margin Container/PanelContainer2/PanelContainer/VBoxContainer/PanelContainer4/VBoxContainer/Label".modulate = Color(1,1,1)
		pass


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
	print("Traditional Button Fired now: ", toggled_on)
	if toggled_on:
		for each in button_group:
			each.disabled = false
	else:
		for each in button_group:
			each.set_pressed(true)
			each.disabled = true
	Global.variant_rules.traditional = toggled_on



func _on_difficulty_button(value):
	Global.difficulty = value # Replace with function body.


func _on_game_speed(speed_set):
	Global.game_speed = speed_set
	Engine.time_scale = speed_set
	pass # Replace with function body.

func _on_guides_pressed(value):
	Global.guides = Global.get(value)  # Replace with function body.
	print(Global.guides)
	pass # Replace with function body.

func _on_ready_pressed():
	$Ready.modulate = Color(0.01176469959319, 0.57254898548126, 1, 0.77254897356033)
	$Card_PopUp.play()
	var tween = create_tween()
	tween.tween_property(self,"position",Vector2(0,-600),0.42).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	create_tween().tween_property(self,"modulate", Color(1,1,1,0.12),.42).set_ease(Tween.EASE_IN)
	$/root/Director.emit_signal("move_on")
	tween.tween_callback(self.queue_free)
	
	pass # Replace with function body.pass # Replace with function body.

func butt_off():
	$Ready.disabled = true
	$Cancel.disabled = true


func _on_cancel_pressed():
	Music.fade_out(.75)
	await get_tree().create_tween().tween_property($"/root/Director/CanvasModulate","color",Color(0,0,0,1),.75).set_ease(Tween.EASE_OUT).finished
	await get_tree().create_timer(.5,false).timeout
	get_tree().change_scene_to_packed(title_menu)
	pass # Replace with function body.



