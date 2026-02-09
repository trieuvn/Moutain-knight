# Victory Screen Controller
extends CanvasLayer

@onready var victory_panel: Panel = $VictoryPanel
@onready var rewards_label: Label = $VictoryPanel/VBoxContainer/RewardsLabel
@onready var continue_button: Button = $VictoryPanel/VBoxContainer/ContinueButton

var coins_earned: int = 0
var soul_essence_earned: int = 0


func _ready() -> void:
	victory_panel.visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Connect to boss defeat event
	EventBus.boss_defeated.connect(_on_boss_defeated)


func _on_boss_defeated(_boss: Node2D) -> void:
	# Calculate rewards
	coins_earned = GameConstants.BLOOD_COINS_PER_BOSS
	soul_essence_earned = GameConstants.SOUL_ESSENCE_PER_BOSS
	
	# Add rewards to player
	GameManager.player_data.blood_coins += coins_earned
	GameManager.player_data.soul_essence += soul_essence_earned
	
	# Update UI
	rewards_label.text = "Rewards:\n+ " + str(coins_earned) + " Blood Coins\n+ " + str(soul_essence_earned) + " Soul Essence"
	
	# Show victory screen after delay
	await get_tree().create_timer(2.0).timeout
	victory_panel.visible = true
	get_tree().paused = true


func _on_continue_pressed() -> void:
	victory_panel.visible = false
	get_tree().paused = false
	
	# Save progress and return to village
	GameManager.save_game()
	get_tree().change_scene_to_file("res://scenes/village/village.tscn")
