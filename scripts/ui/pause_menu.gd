# Pause Menu Controller
extends CanvasLayer

@onready var pause_panel: Panel = $PausePanel
@onready var resume_button: Button = $PausePanel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $PausePanel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $PausePanel/VBoxContainer/QuitButton

var is_paused: bool = false


func _ready() -> void:
	pause_panel.visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	is_paused = !is_paused
	pause_panel.visible = is_paused
	get_tree().paused = is_paused


func _on_resume_pressed() -> void:
	toggle_pause()


func _on_settings_pressed() -> void:
	# TODO: Open settings panel
	print("Settings clicked")


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
