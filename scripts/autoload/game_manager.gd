# Game Manager - Global game state and scene management
extends Node

# ====================
# GAME STATE
# ====================
var is_paused: bool = false
var current_scene: Node = null
var current_dungeon_id: int = 0
var current_room_index: int = 0
var is_in_dungeon: bool = false
var is_in_village: bool = true

# ====================
# PLAYER DATA (persists across scenes)
# ====================
var player_data := {
	"max_hp": GameConstants.PLAYER_MAX_HP,
	"current_hp": GameConstants.PLAYER_MAX_HP,
	"max_stamina": GameConstants.PLAYER_MAX_STAMINA,
	"attack_power": 10.0,
	"defense": 5.0,
	"blood_coins": 0,
	"soul_essence": 0,
	"unlocked_dungeons": [0],  # Dungeon IDs
	"unlocked_villages": [0],  # Village IDs
	"purchased_upgrades": [],
	"inventory": []
}

# ====================
# SAVE/LOAD PATHS
# ====================
const SAVE_PATH := "user://save_data.json"

# ====================
# LIFECYCLE
# ====================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_signals()


func _connect_signals() -> void:
	EventBus.scene_change_requested.connect(_on_scene_change_requested)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

# ====================
# PAUSE SYSTEM
# ====================
func toggle_pause() -> void:
	if is_paused:
		resume_game()
	else:
		pause_game()


func pause_game() -> void:
	is_paused = true
	get_tree().paused = true
	EventBus.game_paused.emit()


func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	EventBus.game_resumed.emit()

# ====================
# SCENE MANAGEMENT
# ====================
func change_scene(scene_path: String) -> void:
	# Fade out effect could be added here
	await get_tree().create_timer(0.1).timeout
	
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to load scene: " + scene_path)
		return
	
	# Wait for scene to be ready
	await get_tree().process_frame
	current_scene = get_tree().current_scene
	EventBus.scene_changed.emit(scene_path)


func _on_scene_change_requested(scene_path: String) -> void:
	change_scene(scene_path)

# ====================
# DUNGEON MANAGEMENT
# ====================
func start_dungeon(dungeon_id: int) -> void:
	current_dungeon_id = dungeon_id
	current_room_index = 0
	is_in_dungeon = true
	is_in_village = false
	EventBus.dungeon_started.emit(dungeon_id)


func complete_dungeon() -> void:
	is_in_dungeon = false
	# Unlock next dungeon if not already unlocked
	var next_dungeon = current_dungeon_id + 1
	if not next_dungeon in player_data.unlocked_dungeons:
		player_data.unlocked_dungeons.append(next_dungeon)
	EventBus.dungeon_completed.emit(current_dungeon_id)


func fail_dungeon() -> void:
	is_in_dungeon = false
	# Reset HP but keep currency
	player_data.current_hp = player_data.max_hp
	EventBus.dungeon_failed.emit()

# ====================
# PLAYER DATA MANAGEMENT
# ====================
func add_blood_coins(amount: int) -> void:
	player_data.blood_coins += amount
	EventBus.update_hud.emit()


func spend_blood_coins(amount: int) -> bool:
	if player_data.blood_coins >= amount:
		player_data.blood_coins -= amount
		EventBus.update_hud.emit()
		return true
	return false


func add_soul_essence(amount: int) -> void:
	player_data.soul_essence += amount
	EventBus.update_hud.emit()


func spend_soul_essence(amount: int) -> bool:
	if player_data.soul_essence >= amount:
		player_data.soul_essence -= amount
		EventBus.update_hud.emit()
		return true
	return false

# ====================
# SAVE/LOAD SYSTEM
# ====================
func save_game() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"player_data": player_data,
			"current_dungeon_id": current_dungeon_id,
			"timestamp": Time.get_datetime_string_from_system()
		}
		save_file.store_string(JSON.stringify(save_data, "\t"))
		save_file.close()
		EventBus.game_saved.emit()
		print("Game saved successfully!")


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return false
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file:
		var json = JSON.new()
		var parse_result = json.parse(save_file.get_as_text())
		save_file.close()
		
		if parse_result == OK:
			var save_data = json.get_data()
			player_data = save_data.player_data
			current_dungeon_id = save_data.current_dungeon_id
			EventBus.game_loaded.emit()
			print("Game loaded successfully!")
			return true
		else:
			push_error("Failed to parse save file.")
	
	return false


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save file deleted.")

# ====================
# SIGNAL HANDLERS
# ====================
func _on_game_paused() -> void:
	pass  # Additional pause logic


func _on_game_resumed() -> void:
	pass  # Additional resume logic
