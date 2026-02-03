# Network Manager - Handles LAN multiplayer connections
extends Node

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)
signal connection_succeeded
signal connection_failed
signal server_started
signal server_closed

# ====================
# EXPORTS
# ====================
@export var default_port: int = 7777
@export var max_players: int = 4

# ====================
# STATE
# ====================
var multiplayer_peer: ENetMultiplayerPeer = null
var is_host: bool = false
var is_connected: bool = false
var connected_peers: Array[int] = []

# Player data for each peer
var player_data: Dictionary = {}  # peer_id -> {name: String, character_data: Dictionary}


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ====================
# HOST SERVER
# ====================
func host_game(port: int = 0) -> Error:
	if port == 0:
		port = default_port
	
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_server(port, max_players)
	
	if error != OK:
		push_error("Failed to create server on port %d: %s" % [port, error_string(error)])
		return error
	
	multiplayer.multiplayer_peer = multiplayer_peer
	is_host = true
	is_connected = true
	
	# Add host to connected peers
	connected_peers.append(1)  # Server is always peer 1
	player_data[1] = {
		"name": GameManager.player_data.character_name,
		"ready": false
	}
	
	server_started.emit()
	EventBus.multiplayer_started.emit()
	print("Server started on port %d" % port)
	
	return OK


# ====================
# JOIN SERVER
# ====================
func join_game(address: String, port: int = 0) -> Error:
	if port == 0:
		port = default_port
	
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_client(address, port)
	
	if error != OK:
		push_error("Failed to connect to %s:%d: %s" % [address, port, error_string(error)])
		return error
	
	multiplayer.multiplayer_peer = multiplayer_peer
	is_host = false
	
	print("Connecting to %s:%d..." % [address, port])
	return OK


# ====================
# DISCONNECT
# ====================
func disconnect_from_game() -> void:
	if multiplayer_peer:
		multiplayer_peer.close()
		multiplayer_peer = null
	
	multiplayer.multiplayer_peer = null
	is_host = false
	is_connected = false
	connected_peers.clear()
	player_data.clear()
	
	server_closed.emit()
	EventBus.multiplayer_ended.emit()
	print("Disconnected from multiplayer")


# ====================
# PEER MANAGEMENT
# ====================
func _on_peer_connected(peer_id: int) -> void:
	print("Peer connected: %d" % peer_id)
	connected_peers.append(peer_id)
	peer_connected.emit(peer_id)
	
	# Request player info from new peer
	if is_host:
		_request_player_info.rpc_id(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer disconnected: %d" % peer_id)
	connected_peers.erase(peer_id)
	player_data.erase(peer_id)
	peer_disconnected.emit(peer_id)
	EventBus.player_left.emit(peer_id)


func _on_connected_to_server() -> void:
	is_connected = true
	var my_id = multiplayer.get_unique_id()
	connected_peers.append(my_id)
	
	print("Connected to server! My ID: %d" % my_id)
	connection_succeeded.emit()
	EventBus.multiplayer_started.emit()


func _on_connection_failed() -> void:
	print("Connection failed!")
	disconnect_from_game()
	connection_failed.emit()


func _on_server_disconnected() -> void:
	print("Server disconnected!")
	disconnect_from_game()


# ====================
# RPC FUNCTIONS
# ====================
@rpc("authority", "call_remote", "reliable")
func _request_player_info() -> void:
	# Client responds with their player info
	_send_player_info.rpc_id(1, {
		"name": GameManager.player_data.character_name,
		"ready": false
	})


@rpc("any_peer", "call_remote", "reliable")
func _send_player_info(info: Dictionary) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	player_data[sender_id] = info
	EventBus.player_joined.emit(sender_id, info)
	
	# Broadcast updated player list to all clients
	if is_host:
		_sync_player_list.rpc(player_data)


@rpc("authority", "call_remote", "reliable")
func _sync_player_list(data: Dictionary) -> void:
	player_data = data


@rpc("any_peer", "call_remote", "reliable")
func set_player_ready(ready: bool) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id == 0:
		sender_id = multiplayer.get_unique_id()
	
	if player_data.has(sender_id):
		player_data[sender_id].ready = ready
		
		if is_host:
			_sync_player_list.rpc(player_data)
			_check_all_ready()


func _check_all_ready() -> bool:
	for peer_id in player_data:
		if not player_data[peer_id].ready:
			return false
	return true


@rpc("authority", "call_remote", "reliable")
func start_game_for_all() -> void:
	if not is_host:
		return
	
	if not _check_all_ready():
		push_warning("Not all players are ready!")
		return
	
	# Load game scene for all peers
	_load_game_scene.rpc()


@rpc("authority", "call_remote", "reliable")
func _load_game_scene() -> void:
	EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")


# ====================
# UTILITY
# ====================
func get_player_count() -> int:
	return connected_peers.size()


func get_peer_name(peer_id: int) -> String:
	if player_data.has(peer_id):
		return player_data[peer_id].name
	return "Unknown"


func is_server() -> bool:
	return is_host


func get_my_id() -> int:
	return multiplayer.get_unique_id()
