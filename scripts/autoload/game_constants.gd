# Game Constants and Enums for Mountain Knight
class_name GameConstants
extends RefCounted

# ====================
# GAME SETTINGS
# ====================
const GAME_VERSION := "0.1.0"
const GAME_TITLE := "Mountain Knight"

# ====================
# PLAYER CONSTANTS
# ====================
const PLAYER_MAX_HP := 100.0
const PLAYER_MAX_STAMINA := 100.0
const PLAYER_MOVE_SPEED := 200.0
const PLAYER_RUN_SPEED := 320.0
const PLAYER_JUMP_VELOCITY := -550.0
const PLAYER_GRAVITY_SCALE := 1.0

# Stamina costs
const STAMINA_DODGE_COST := 25.0
const STAMINA_LIGHT_ATTACK_COST := 15.0
const STAMINA_HEAVY_ATTACK_COST := 30.0
const STAMINA_REGEN_RATE := 30.0  # per second
const STAMINA_REGEN_DELAY := 1.0  # seconds before regen starts

# Dodge roll
const DODGE_DURATION := 0.4
const DODGE_SPEED := 400.0
const DODGE_IFRAMES := 0.35  # invincibility duration

# Attack timings
const LIGHT_ATTACK_DURATION := 0.3
const HEAVY_ATTACK_DURATION := 0.6
const COMBO_WINDOW := 0.4  # time to input next combo attack

# ====================
# COMBAT CONSTANTS
# ====================
const KNOCKBACK_FORCE := 200.0
const STAGGER_DURATION := 0.3
const INVINCIBILITY_AFTER_HIT := 0.5
const CRITICAL_HIT_MULTIPLIER := 1.5
const CRITICAL_HIT_CHANCE := 0.1

# ====================
# ENEMY CONSTANTS
# ====================
const ENEMY_DETECTION_RANGE := 300.0
const ENEMY_ATTACK_RANGE := 50.0
const ENEMY_CHASE_SPEED := 100.0

# ====================
# BOSS CONSTANTS
# ====================
const BOSS_PHASE_TRANSITION_TIME := 2.0
const BOSS_TELEGRAPH_TIME := 0.5

# ====================
# DUNGEON CONSTANTS
# ====================
const ROOM_TRANSITION_TIME := 0.5
const MIN_ROOMS_PER_DUNGEON := 5
const MAX_ROOMS_PER_DUNGEON := 8

# ====================
# ECONOMY CONSTANTS
# ====================
const BLOOD_COINS_PER_ENEMY := 10
const BLOOD_COINS_PER_BOSS := 100
const SOUL_ESSENCE_PER_BOSS := 1

# ====================
# ENUMS
# ====================
enum PlayerState {
	IDLE,
	MOVE,
	JUMP,
	FALL,
	DODGE,
	LIGHT_ATTACK,
	HEAVY_ATTACK,
	HURT,
	DEATH
}

enum EnemyState {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	HURT,
	DEATH
}

enum BossPhase {
	PHASE_1,
	PHASE_2,
	PHASE_3,
	TRANSITION,
	DEFEATED
}

enum DamageType {
	PHYSICAL,
	HOLY,
	DARK,
	FIRE
}

enum ItemType {
	WEAPON,
	CONSUMABLE,
	KEY_ITEM,
	UPGRADE_MATERIAL
}

enum RoomType {
	COMBAT,
	TREASURE,
	TRANSITION,
	BOSS,
	START
}

# ====================
# LAYERS
# ====================
const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const LAYER_PLAYER_HITBOX := 3
const LAYER_ENEMY_HITBOX := 4
const LAYER_ENVIRONMENT := 5
const LAYER_INTERACTABLE := 6
