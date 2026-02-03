# Main Menu Controller
extends Control

@onready var new_game_button: Button = $CenterContainer/ButtonContainer/NewGameButton
@onready var continue_button: Button = $CenterContainer/ButtonContainer/ContinueButton
@onready var coop_button: Button = $CenterContainer/ButtonContainer/CoopButton
@onready var settings_button: Button = $CenterContainer/ButtonContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/ButtonContainer/QuitButton


func _ready() -> void:
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	coop_button.pressed.connect(_on_coop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Check if save exists
	continue_button.disabled = not FileAccess.file_exists("user://save_data.json")
	
	# Add hover animations
	_setup_button_animations()


func _setup_button_animations() -> void:
	var buttons = [new_game_button, continue_button, coop_button, settings_button, quit_button]
	for button in buttons:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))


func _on_button_hover(button: Button) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)


func _on_button_unhover(button: Button) -> void:
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)


func _on_new_game_pressed() -> void:
	# Reset player data and start new game
	GameManager.player_data = {
		"max_hp": GameConstants.PLAYER_MAX_HP,
		"current_hp": GameConstants.PLAYER_MAX_HP,
		"max_stamina": GameConstants.PLAYER_MAX_STAMINA,
		"attack_power": 10.0,
		"defense": 5.0,
		"blood_coins": 0,
		"soul_essence": 0,
		"unlocked_dungeons": [0],
		"unlocked_villages": [0],
		"purchased_upgrades": [],
		"inventory": []
	}
	GameManager.delete_save()
	
	# Go to village
	EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")


func _on_continue_pressed() -> void:
	if GameManager.load_game():
		EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")


func _on_coop_pressed() -> void:
	# TODO: Open LAN co-op lobby
	print("LAN Co-op - Coming soon!")


func _on_settings_pressed() -> void:
	# TODO: Open settings menu
	print("Settings - Coming soon!")


func _on_quit_pressed() -> void:
	get_tree().quit()
