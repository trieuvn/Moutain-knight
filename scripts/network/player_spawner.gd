# Multiplayer Player Spawner - Handles spawning and syncing players
extends Node

const PLAYER_SCENE = preload("res://scenes/player/player.tscn")

var spawned_players: Dictionary = {}  # peer_id -> Player node


func _ready() -> void:
	# Connect to network events
	if has_node("/root/NetworkManager"):
		var network = get_node("/root/NetworkManager")
		network.peer_connected.connect(_on_peer_connected)
		network.peer_disconnected.connect(_on_peer_disconnected)


func spawn_all_players() -> void:
	var network = get_node("/root/NetworkManager")
	
	for peer_id in network.connected_peers:
		spawn_player(peer_id)


func spawn_player(peer_id: int) -> Node2D:
	if spawned_players.has(peer_id):
		return spawned_players[peer_id]
	
	var player = PLAYER_SCENE.instantiate()
	player.name = "Player_%d" % peer_id
	
	# Set multiplayer authority
	player.set_multiplayer_authority(peer_id)
	
	# Find spawn point
	var spawn_points = get_tree().get_nodes_in_group("player_spawn")
	var spawn_index = spawned_players.size() % max(spawn_points.size(), 1)
	
	if spawn_points.size() > 0:
		player.global_position = spawn_points[spawn_index].global_position
	else:
		player.global_position = Vector2(100 + spawn_index * 100, 200)
	
	# Add to scene
	var spawn_parent = get_node_or_null("../PlayerContainer")
	if spawn_parent:
		spawn_parent.add_child(player)
	else:
		get_parent().add_child(player)
	
	spawned_players[peer_id] = player
	
	# If this is the local player
	if peer_id == multiplayer.get_unique_id():
		player.add_to_group("local_player")
		# Enable camera
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			camera.make_current()
	else:
		# Remote player - disable local input
		player.add_to_group("remote_player")
		player.set_process_input(false)
	
	return player


func despawn_player(peer_id: int) -> void:
	if spawned_players.has(peer_id):
		var player = spawned_players[peer_id]
		if is_instance_valid(player):
			player.queue_free()
		spawned_players.erase(peer_id)


func despawn_all_players() -> void:
	for peer_id in spawned_players.keys():
		despawn_player(peer_id)


func get_local_player() -> Node2D:
	var my_id = multiplayer.get_unique_id()
	if spawned_players.has(my_id):
		return spawned_players[my_id]
	return null


func get_player_by_id(peer_id: int) -> Node2D:
	if spawned_players.has(peer_id):
		return spawned_players[peer_id]
	return null


func _on_peer_connected(peer_id: int) -> void:
	# Spawn new player after a short delay
	await get_tree().create_timer(0.5).timeout
	spawn_player(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	despawn_player(peer_id)
