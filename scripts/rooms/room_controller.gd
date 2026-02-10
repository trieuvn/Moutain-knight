# Room Controller - Handles room clearing logic
extends Node2D

@export var room_type: String = "combat"  # combat, treasure, boss
@onready var enemies_container: Node2D = $Enemies

var enemies_alive: int = 0
var room_cleared: bool = false


func _ready() -> void:
	# Count enemies
	call_deferred("_count_enemies")
	
	# Connect to enemy death event
	EventBus.enemy_killed.connect(_on_enemy_killed)


func _count_enemies() -> void:
	if not enemies_container:
		return
	
	enemies_alive = 0
	for child in enemies_container.get_children():
		if child is BaseEnemy:
			enemies_alive += 1
	
	print("Room has %d enemies" % enemies_alive)
	
	# Check if already cleared (no enemies)
	if enemies_alive == 0 and room_type != "treasure":
		_room_cleared()


func _on_enemy_killed(enemy: Node2D, _reward: int) -> void:
	# Only count enemies in this room
	if not enemies_container:
		return
	
	if enemy.get_parent() == enemies_container:
		enemies_alive -= 1
		print("Enemy killed! %d remaining" % enemies_alive)
		
		if enemies_alive <= 0 and not room_cleared:
			_room_cleared()


func _room_cleared() -> void:
	room_cleared = true
	print("=== ROOM CLEARED ===")
	EventBus.room_cleared.emit(self)
	
	# Visual feedback
	var label = Label.new()
	label.text = "ROOM CLEARED!"
	label.modulate = Color(1, 1, 0.5, 1)
	label.position = Vector2(-100, -150)
	label.z_index = 100
	add_child(label)
	
	# Fade out label
	await get_tree().create_timer(1.0).timeout
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	await tween.finished
	label.queue_free()
