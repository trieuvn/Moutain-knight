# Simple Dungeon Progression Manager
extends Node

# Room sequence for dungeon
var room_sequence: Array[String] = [
	"res://scenes/rooms/combat_room_1.tscn",
	"res://scenes/rooms/combat_room_2.tscn",
	"res://scenes/rooms/treasure_room_1.tscn",
	"res://scenes/rooms/boss_room_1.tscn"
]

var current_room_index: int = 0


func _ready() -> void:
	# Connect to room cleared event
	EventBus.room_cleared.connect(_on_room_cleared)


func start_dungeon() -> void:
	current_room_index = 0
	_load_room(current_room_index)


func _on_room_cleared(_room: Node2D) -> void:
	print("Room cleared! Moving to next room...")
	await get_tree().create_timer(2.0).timeout
	
	current_room_index += 1
	
	if current_room_index >= room_sequence.size():
		# Dungeon complete!
		print("Dungeon complete!")
		EventBus.dungeon_completed.emit(0)
		return
	
	_load_room(current_room_index)


func _load_room(index: int) -> void:
	if index < 0 or index >= room_sequence.size():
		return
	
	var room_path = room_sequence[index]
	EventBus.scene_change_requested.emit(room_path)
