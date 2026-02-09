# Village Controller - Manages village interactions
extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var blacksmith: Area2D = $NPCs/Blacksmith
@onready var merchant: Area2D = $NPCs/Merchant
@onready var elder: Area2D = $NPCs/Elder
@onready var dungeon_portal: Area2D = $DungeonPortal

var current_interactable: Area2D = null
var is_in_ui: bool = false


func _ready() -> void:
	EventBus.entered_village.emit()
	GameManager.is_in_village = true
	GameManager.is_in_dungeon = false
	
	# Auto-save when entering village
	GameManager.save_game()
	
	_connect_npc_signals()
	_update_player_health()


func _connect_npc_signals() -> void:
	# Blacksmith
	blacksmith.body_entered.connect(_on_npc_entered.bind(blacksmith))
	blacksmith.body_exited.connect(_on_npc_exited.bind(blacksmith))
	
	# Merchant
	merchant.body_entered.connect(_on_npc_entered.bind(merchant))
	merchant.body_exited.connect(_on_npc_exited.bind(merchant))
	
	# Elder
	elder.body_entered.connect(_on_npc_entered.bind(elder))
	elder.body_exited.connect(_on_npc_exited.bind(elder))
	
	# Dungeon Portal
	dungeon_portal.body_entered.connect(_on_npc_entered.bind(dungeon_portal))
	dungeon_portal.body_exited.connect(_on_npc_exited.bind(dungeon_portal))


func _update_player_health() -> void:
	# Restore player health in village
	GameManager.player_data.current_hp = GameManager.player_data.max_hp
	EventBus.player_health_changed.emit(
		GameManager.player_data.current_hp,
		GameManager.player_data.max_hp
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable and not is_in_ui:
		_interact_with(current_interactable)


func _on_npc_entered(body: Node2D, npc: Area2D) -> void:
	if body.is_in_group("player"):
		current_interactable = npc
		var interact_label = npc.get_node_or_null("InteractLabel")
		if interact_label:
			interact_label.visible = true


func _on_npc_exited(body: Node2D, npc: Area2D) -> void:
	if body.is_in_group("player") and current_interactable == npc:
		current_interactable = null
		var interact_label = npc.get_node_or_null("InteractLabel")
		if interact_label:
			interact_label.visible = false


func _interact_with(npc: Area2D) -> void:
	match npc.name:
		"Blacksmith":
			_open_blacksmith()
		"Merchant":
			_open_shop()
		"Elder":
			_open_upgrades()
		"DungeonPortal":
			_enter_dungeon()


func _open_blacksmith() -> void:
	print("Blacksmith: 'Your weapons look worn, knight.'")
	EventBus.npc_interacted.emit(blacksmith)
	# TODO: Open blacksmith UI for weapon upgrades


func _open_shop() -> void:
	print("Merchant: 'What can I get for you today?'")
	EventBus.shop_opened.emit("merchant")
	# TODO: Open shop UI


func _open_upgrades() -> void:
	print("Elder: 'I sense great power within you...'")
	EventBus.npc_interacted.emit(elder)
	# TODO: Open upgrade UI using Soul Essence


func _enter_dungeon() -> void:
	EventBus.left_village.emit()
	GameManager.is_in_village = false
	
	# Load dungeon combat room with enemies
	EventBus.scene_change_requested.emit("res://scenes/rooms/combat_room_1.tscn")
