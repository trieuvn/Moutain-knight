# Event Bus - Centralized signal hub for decoupled communication
extends Node

# ====================
# PLAYER SIGNALS
# ====================
signal player_spawned(player: Node2D)
signal player_died(player: Node2D)
signal player_health_changed(current: float, max_health: float)
signal player_stamina_changed(current: float, max_stamina: float)
signal player_took_damage(amount: float, source: Node2D)
signal player_healed(amount: float)

# ====================
# COMBAT SIGNALS
# ====================
signal damage_dealt(target: Node2D, amount: float, type: int)
signal enemy_killed(enemy: Node2D, reward: int)
signal boss_killed(boss: Node2D, reward: int)
signal critical_hit(target: Node2D, amount: float)

# ====================
# BOSS SIGNALS
# ====================
signal boss_spawned(boss: Node2D)
signal boss_phase_changed(boss: Node2D, phase: int)
signal boss_health_changed(current: float, max_health: float)
signal boss_defeated(boss: Node2D)

# ====================
# DUNGEON SIGNALS
# ====================
signal room_entered(room: Node2D, room_type: int)
signal room_cleared(room: Node2D)
signal dungeon_started(dungeon_id: int)
signal dungeon_completed(dungeon_id: int)
signal dungeon_failed()

# ====================
# VILLAGE SIGNALS
# ====================
signal entered_village()
signal left_village()
signal npc_interacted(npc: Node2D)
signal shop_opened(shop_type: String)
signal item_purchased(item_id: String, cost: int)
signal item_sold(item_id: String, value: int)
signal upgrade_purchased(upgrade_id: String)

# ====================
# GAME STATE SIGNALS
# ====================
signal game_paused()
signal game_resumed()
signal game_saved()
signal game_loaded()
signal scene_change_requested(scene_path: String)
signal scene_changed(scene_path: String)

# ====================
# UI SIGNALS
# ====================
signal show_damage_number(position: Vector2, amount: float, is_critical: bool)
signal show_notification(message: String, duration: float)
signal show_dialogue(npc_name: String, dialogue_id: String)
signal dialogue_ended()
signal update_hud()

# ====================
# MULTIPLAYER SIGNALS
# ====================
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal server_started()
signal server_stopped()
signal client_connected()
signal client_disconnected()

# ====================
# AUDIO SIGNALS
# ====================
signal play_sfx(sfx_name: String)
signal play_music(music_name: String)
signal stop_music()
signal set_music_volume(volume: float)
signal set_sfx_volume(volume: float)
