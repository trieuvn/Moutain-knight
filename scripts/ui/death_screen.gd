# Death Screen Controller
extends CanvasLayer

@onready var death_panel: Panel = $DeathPanel
@onready var respawn_button: Button = $DeathPanel/VBoxContainer/RespawnButton
@onready var quit_button: Button = $DeathPanel/VBoxContainer/QuitButton
@onready var coins_lost_label: Label = $DeathPanel/VBoxContainer/CoinsLostLabel

var coins_lost: int = 0


func _ready() -> void:
	death_panel.visible = false
	respawn_button.pressed.connect(_on_respawn_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect to player death event
	EventBus.player_died.connect(_on_player_died)


func _on_player_died(_player: Node2D) -> void:
	# Calculate coins lost (lose 50% on death - roguelite penalty)
	coins_lost = GameManager.player_data.blood_coins / 2
	GameManager.player_data.blood_coins -= coins_lost
	
	coins_lost_label.text = "Blood Coins Lost: " + str(coins_lost)
	
	# Show death screen after delay
	await get_tree().create_timer(1.5).timeout
	death_panel.visible = true
	get_tree().paused = true


func _on_respawn_pressed() -> void:
	death_panel.visible = false
	get_tree().paused = false
	
	# Return to village
	get_tree().change_scene_to_file("res://scenes/village/village.tscn")


func _on_quit_pressed() -> void:
	death_panel.visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
