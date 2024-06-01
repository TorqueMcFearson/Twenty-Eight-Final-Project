extends Control

const DEFAULT = "Twenty-Eight has many different rules. Customize the ones you are fimilar with or would like to try. These cannot be changed during the match."
const american = "[b]Filthy American Mode:[/b] This changes the order of value and rank of each card to resemble something that is more fimilar in american card games.\n\n[color=green]On[/color] - Cards ranked low-to-high as 7, 8, 9, 10, J, Q, K, A\n[color=red]On[/color] - Cards ranked low-to-high as 7, 8, Q, K, 10, A, 9, J"
const partner_bid = "[b]Partner Overbid Minimum:[/b] Sets a minimum bid for bidding if your partner was the last to bid.\n\nON - minimum of 20.\nOFF - no minimum"
const final_bet = "[b]Final Post Trump Bet:[/b] After everyone has been dealt eight cards, the bidding team may increase the bid increase their bid to 24."
const bet_pips = "[b]Bet Based Scoring:[/b] 
If the bid was 19 or less, the bidding team wins 1 game point if successful, but loses 2 game points if they fail.
For bids from 20 to 24, the bidding team wins 2 game points or loses 3 game points.
For bids of 25 or more, the bidding team wins 3 game points or loses 4 game points."
enum {AMERICAN,PARTNER_BID,FINAL_BET,BET_PIPS}
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _rule_hover(rule):
	match rule:
		AMERICAN:
			$"Margin Container/PanelContainer3/Rule Text".text = american
			$"Margin Container/PanelContainer3/Rule Text2".visible = true
		PARTNER_BID:
			$"Margin Container/PanelContainer3/Rule Text".text = partner_bid
		FINAL_BET:
			$"Margin Container/PanelContainer3/Rule Text".text = final_bet
		BET_PIPS:
			$"Margin Container/PanelContainer3/Rule Text".text = bet_pips
	pass # Replace with function body.


func _rule_hover_exit(rule):
		$"Margin Container/PanelContainer3/Rule Text".text = DEFAULT
		$"Margin Container/PanelContainer3/Rule Text2".visible = false



func _on_checkbutton_toggled(toggled_on, rule):
	Global.variant_rules[rule] = true if toggled_on else false
	print(rule,Global.variant_rules[rule])
	pass # Replace with function body.
