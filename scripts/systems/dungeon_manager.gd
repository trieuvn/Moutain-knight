# Dungeon Manager - Manages room progression and dungeon state
extends Node

signal room_changed(room_scene: Node2D)
signal dungeon_started
signal dungeon_completed
signal dungeon_failed

# ====================
# DUNGEON DATA
# ====================
@export var dungeon_id: int = 0

# Room pools by type
var combat_rooms: Array[String] = [
	"res://scenes/rooms/combat_room_1.tscn",
	"res://scenes/rooms/combat_room_2.tscn",
	"res://scenes/rooms/combat_room_3.tscn",
]

var treasure_rooms: Array[String] = [
	"res://scenes/rooms/treasure_room_1.tscn",
]

var transition_rooms: Array[String] = [
	"res://scenes/rooms/transition_room_1.tscn",
]

var boss_rooms: Array[String] = [
	"res://scenes/rooms/boss_room_1.tscn",
]

# Current dungeon state
var current_room_index: int = 0
var room_sequence: Array[Dictionary] = []
var current_room: Node2D = null
var player_instance: Node2D = null

@onready var room_container: Node2D = $RoomContainer
@onready var transition_overlay: ColorRect = $TransitionOverlay


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.player_died.connect(_on_player_died)

# ====================
# DUNGEON GENERATION
# ====================
func generate_dungeon(num_rooms: int = 5) -> void:
	room_sequence.clear()
	
	# Start room
	room_sequence.append({
		"type": "start",
		"scene": "res://scenes/rooms/start_room.tscn"
	})
	
	# Generate middle rooms
	for i in range(num_rooms - 2):
		var room_type = _pick_room_type(i, num_rooms - 2)
		var room_scene = _pick_room_scene(room_type)
		room_sequence.append({
			"type": room_type,
			"scene": room_scene
		})
	
	# Boss room
	room_sequence.append({
		"type": "boss",
		"scene": boss_rooms.pick_random() if boss_rooms.size() > 0 else "res://scenes/rooms/boss_room_1.tscn"
	})


func _pick_room_type(index: int, total: int) -> String:
	# Ensure variety in room types
	var roll = randf()
	
	if roll < 0.6:
		return "combat"
	elif roll < 0.8:
		return "transition"
	else:
		return "treasure"


func _pick_room_scene(room_type: String) -> String:
	match room_type:
		"combat":
			return combat_rooms.pick_random() if combat_rooms.size() > 0 else "res://scenes/rooms/combat_room_1.tscn"
		"treasure":
			return treasure_rooms.pick_random() if treasure_rooms.size() > 0 else "res://scenes/rooms/treasure_room_1.tscn"
		"transition":
			return transition_rooms.pick_random() if transition_rooms.size() > 0 else "res://scenes/rooms/transition_room_1.tscn"
		_:
			return "res://scenes/rooms/combat_room_1.tscn"

# ====================
# ROOM MANAGEMENT
# ====================
func start_dungeon() -> void:
	GameManager.start_dungeon(dungeon_id)
	current_room_index = 0
	generate_dungeon()
	load_room(0)
	dungeon_started.emit()


func load_room(index: int) -> void:
	if index < 0 or index >= room_sequence.size():
		return
	
	current_room_index = index
	GameManager.current_room_index = index
	
	await _transition_out()
	
	# Clear current room
	if current_room:
		current_room.queue_free()
		await get_tree().process_frame
	
	# Load new room
	var room_data = room_sequence[index]
	var room_scene = load(room_data.scene)
	
	if room_scene:
		current_room = room_scene.instantiate()
		room_container.add_child(current_room)
		
		# Spawn player
		_spawn_player_in_room()
		
		# Connect room signals
		if current_room.has_signal("room_cleared"):
			current_room.room_cleared.connect(_on_room_cleared.bind(current_room))
		
		room_changed.emit(current_room)
		EventBus.room_entered.emit(current_room, _get_room_type_enum(room_data.type))
	
	await _transition_in()


func _spawn_player_in_room() -> void:
	# Find spawn point
	var spawn_point = current_room.get_node_or_null("PlayerSpawnPoint")
	var spawn_pos = spawn_point.global_position if spawn_point else Vector2(100, 200)
	
	# Create or move player
	if player_instance == null or not is_instance_valid(player_instance):
		var player_scene = load("res://scenes/player/player.tscn")
		player_instance = player_scene.instantiate()
		current_room.add_child(player_instance)
	else:
		if player_instance.get_parent():
			player_instance.get_parent().remove_child(player_instance)
		current_room.add_child(player_instance)
	
	player_instance.global_position = spawn_pos
	
	# Set as target for boss if boss room
	var boss = current_room.get_node_or_null("Boss")
	if boss and boss.has_method("set_target"):
		boss.set_target(player_instance)


func next_room() -> void:
	if current_room_index < room_sequence.size() - 1:
		load_room(current_room_index + 1)
	else:
		# Dungeon complete!
		_complete_dungeon()

# ====================
# TRANSITIONS
# ====================
func _transition_out() -> void:
	if transition_overlay:
		var tween = create_tween()
		tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.3)
		await tween.finished


func _transition_in() -> void:
	if transition_overlay:
		var tween = create_tween()
		tween.tween_property(transition_overlay, "modulate:a", 0.0, 0.3)
		await tween.finished


func _get_room_type_enum(type_string: String) -> int:
	match type_string:
		"combat": return GameConstants.RoomType.COMBAT
		"treasure": return GameConstants.RoomType.TREASURE
		"transition": return GameConstants.RoomType.TRANSITION
		"boss": return GameConstants.RoomType.BOSS
		"start": return GameConstants.RoomType.START
		_: return GameConstants.RoomType.COMBAT

# ====================
# SIGNAL HANDLERS
# ====================
func _on_room_cleared(room: Node2D = null) -> void:
	# Enable door to next room
	var exit_door = current_room.get_node_or_null("ExitDoor")
	if exit_door and exit_door.has_method("unlock"):
		exit_door.unlock()


func _on_boss_defeated(_boss: Node2D) -> void:
	await get_tree().create_timer(2.0).timeout
	_complete_dungeon()


func _on_player_died(_player: Node2D) -> void:
	await get_tree().create_timer(1.0).timeout
	dungeon_failed.emit()
	GameManager.fail_dungeon()
	EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")


func _complete_dungeon() -> void:
	dungeon_completed.emit()
	GameManager.complete_dungeon()
	await get_tree().create_timer(1.0).timeout
	EventBus.scene_change_requested.emit("res://scenes/village/village.tscn")
