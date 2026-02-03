# Lobby UI Controller
extends Control

@onready var host_button: Button = $VBox/ModeSelect/HostButton
@onready var join_button: Button = $VBox/ModeSelect/JoinButton
@onready var host_panel: VBoxContainer = $VBox/HostPanel
@onready var join_panel: VBoxContainer = $VBox/JoinPanel
@onready var lobby_panel: VBoxContainer = $VBox/LobbyPanel
@onready var mode_select: HBoxContainer = $VBox/ModeSelect

# Host panel
@onready var host_port_input: LineEdit = $VBox/HostPanel/PortInput
@onready var start_host_button: Button = $VBox/HostPanel/StartHostButton

# Join panel
@onready var address_input: LineEdit = $VBox/JoinPanel/AddressInput
@onready var join_port_input: LineEdit = $VBox/JoinPanel/PortInput
@onready var connect_button: Button = $VBox/JoinPanel/ConnectButton

# Lobby panel
@onready var status_label: Label = $VBox/LobbyPanel/StatusLabel
@onready var player_list: VBoxContainer = $VBox/LobbyPanel/PlayerList
@onready var ready_button: Button = $VBox/LobbyPanel/ReadyButton
@onready var start_game_button: Button = $VBox/LobbyPanel/StartGameButton
@onready var disconnect_button: Button = $VBox/LobbyPanel/DisconnectButton

@onready var back_button: Button = $VBox/BackButton

var network: Node


func _ready() -> void:
	network = get_node_or_null("/root/NetworkManager")
	
	_connect_signals()
	_show_mode_select()


func _connect_signals() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	start_host_button.pressed.connect(_on_start_host_pressed)
	connect_button.pressed.connect(_on_connect_pressed)
	ready_button.toggled.connect(_on_ready_toggled)
	start_game_button.pressed.connect(_on_start_game_pressed)
	disconnect_button.pressed.connect(_on_disconnect_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	if network:
		network.server_started.connect(_on_server_started)
		network.connection_succeeded.connect(_on_connection_succeeded)
		network.connection_failed.connect(_on_connection_failed)
		network.peer_connected.connect(_on_peer_connected)
		network.peer_disconnected.connect(_on_peer_disconnected)


func _show_mode_select() -> void:
	mode_select.visible = true
	host_panel.visible = false
	join_panel.visible = false
	lobby_panel.visible = false


func _show_host_panel() -> void:
	mode_select.visible = false
	host_panel.visible = true
	join_panel.visible = false
	lobby_panel.visible = false


func _show_join_panel() -> void:
	mode_select.visible = false
	host_panel.visible = false
	join_panel.visible = true
	lobby_panel.visible = false


func _show_lobby_panel() -> void:
	mode_select.visible = false
	host_panel.visible = false
	join_panel.visible = false
	lobby_panel.visible = true


func _update_player_list() -> void:
	if not network:
		return
	
	# Clear existing player labels (except header)
	for child in player_list.get_children():
		if child.name != "PlayerListLabel":
			child.queue_free()
	
	# Add player labels
	for peer_id in network.player_data:
		var player_info = network.player_data[peer_id]
		var label = Label.new()
		var ready_text = " [READY]" if player_info.get("ready", false) else ""
		var host_text = " (Host)" if peer_id == 1 else ""
		label.text = "• %s%s%s" % [player_info.get("name", "Player"), host_text, ready_text]
		label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		player_list.add_child(label)


# ====================
# BUTTON HANDLERS
# ====================
func _on_host_pressed() -> void:
	_show_host_panel()


func _on_join_pressed() -> void:
	_show_join_panel()


func _on_start_host_pressed() -> void:
	if not network:
		return
	
	var port = int(host_port_input.text) if host_port_input.text.is_valid_int() else 7777
	var error = network.host_game(port)
	
	if error != OK:
		status_label.text = "Failed to start server!"
		status_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))


func _on_connect_pressed() -> void:
	if not network:
		return
	
	var address = address_input.text
	var port = int(join_port_input.text) if join_port_input.text.is_valid_int() else 7777
	
	status_label.text = "Connecting..."
	var error = network.join_game(address, port)
	
	if error != OK:
		status_label.text = "Failed to connect!"


func _on_ready_toggled(is_ready: bool) -> void:
	if network:
		network.set_player_ready.rpc(is_ready)
	
	ready_button.text = "READY!" if is_ready else "READY"


func _on_start_game_pressed() -> void:
	if network and network.is_server():
		network.start_game_for_all()


func _on_disconnect_pressed() -> void:
	if network:
		network.disconnect_from_game()
	_show_mode_select()


func _on_back_pressed() -> void:
	if network and network.is_connected:
		network.disconnect_from_game()
	EventBus.scene_change_requested.emit("res://scenes/ui/main_menu.tscn")


# ====================
# NETWORK CALLBACKS
# ====================
func _on_server_started() -> void:
	_show_lobby_panel()
	status_label.text = "Server started! Waiting for players..."
	status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	start_game_button.visible = true
	_update_player_list()


func _on_connection_succeeded() -> void:
	_show_lobby_panel()
	status_label.text = "Connected!"
	status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	start_game_button.visible = false
	_update_player_list()


func _on_connection_failed() -> void:
	_show_join_panel()
	status_label.text = "Connection failed!"
	status_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5))


func _on_peer_connected(peer_id: int) -> void:
	await get_tree().create_timer(0.2).timeout
	_update_player_list()


func _on_peer_disconnected(peer_id: int) -> void:
	_update_player_list()
