# Base Enemy - Parent class for all enemies
class_name BaseEnemy
extends CharacterBody2D

# ====================
# SIGNALS
# ====================
signal died(reward: int)
signal damaged(amount: float)
signal attack_started
signal attack_ended

# ====================
# EXPORTS
# ====================
@export_category("Enemy Stats")
@export var max_hp: float = 50.0
@export var attack_damage: float = 15.0
@export var move_speed: float = 80.0
@export var detection_range: float = 300.0
@export var attack_range: float = 50.0
@export var blood_coin_reward: int = 10

@export_category("Combat")
@export var attack_cooldown: float = 1.5
@export var stagger_threshold: float = 20.0  # Damage needed to stagger

# ====================
# COMPONENTS
# ====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_timer: Timer = $AttackTimer

# ====================
# STATE VARIABLES
# ====================
var target: Node2D = null
var facing_direction: int = 1
var is_attacking: bool = false
var can_attack: bool = true
var is_dead: bool = false
var accumulated_damage: float = 0.0  # For stagger calculation

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	_load_sprites()
	_initialize_components()
	_connect_signals()


func _load_sprites() -> void:
	# Override in child classes for specific sprites
	# Default: load skeleton sprites using SpriteLoader
	if sprite:
		SpriteLoader.setup_skeleton_sprite_frames(sprite)


func _initialize_components() -> void:
	health_component.max_health = max_hp
	health_component.current_health = max_hp
	
	hitbox.owner_entity = self
	hitbox.damage = attack_damage
	
	hurtbox.owner_entity = self
	
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true


func _connect_signals() -> void:
	health_component.died.connect(_on_died)
	health_component.damage_taken.connect(_on_damage_taken)
	hurtbox.damage_received.connect(_on_damage_received)
	attack_timer.timeout.connect(_on_attack_cooldown_finished)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

# ====================
# MOVEMENT
# ====================
func move_towards_target() -> void:
	if target == null:
		return
	
	var direction = sign(target.global_position.x - global_position.x)
	velocity.x = direction * move_speed
	update_facing(direction)


func stop_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, move_speed * 0.5)


func update_facing(direction: int) -> void:
	if direction != 0:
		facing_direction = direction
		sprite.flip_h = facing_direction < 0

# ====================
# DETECTION
# ====================
func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body


func _on_detection_body_exited(body: Node2D) -> void:
	if body == target:
		target = null


func is_target_in_range() -> bool:
	if target == null:
		return false
	return global_position.distance_to(target.global_position) <= attack_range


func is_target_detected() -> bool:
	return target != null

# ====================
# COMBAT
# ====================
func start_attack() -> void:
	if not can_attack or is_attacking:
		return
	
	is_attacking = true
	can_attack = false
	attack_started.emit()


func end_attack() -> void:
	is_attacking = false
	hitbox.disable()
	attack_timer.start()
	attack_ended.emit()


func enable_hitbox() -> void:
	hitbox.enable()


func disable_hitbox() -> void:
	hitbox.disable()


func _on_attack_cooldown_finished() -> void:
	can_attack = true

# ====================
# DAMAGE
# ====================
func _on_damage_received(amount: float, knockback: Vector2, _damage_type: int, attacker: Node2D) -> void:
	if is_dead:
		return
	
	health_component.take_damage(amount, attacker)
	velocity += knockback
	
	# Accumulate damage for stagger
	accumulated_damage += amount
	
	damaged.emit(amount)
	EventBus.damage_dealt.emit(self, amount, _damage_type)
	
	# Check for stagger
	if accumulated_damage >= stagger_threshold:
		accumulated_damage = 0
		_trigger_stagger()


func _trigger_stagger() -> void:
	# Override in child classes for custom stagger behavior
	state_machine.change_state(&"Hurt")


func _on_damage_taken(amount: float, attacker: Node2D) -> void:
	# Visual feedback
	_flash_damage()


func _flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)


func _on_died() -> void:
	if is_dead:
		return
	
	is_dead = true
	
	# Disable collision
	set_collision_layer_value(2, false)
	set_collision_mask_value(1, false)
	hurtbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitoring", false)
	
	# Give rewards
	GameManager.add_blood_coins(blood_coin_reward)
	
	died.emit(blood_coin_reward)
	EventBus.enemy_killed.emit(self, blood_coin_reward)
	
	# Play death animation and remove
	state_machine.change_state(&"Death")

# ====================
# UTILITY
# ====================
func get_distance_to_target() -> float:
	if target == null:
		return INF
	return global_position.distance_to(target.global_position)


func get_direction_to_target() -> int:
	if target == null:
		return facing_direction
	return sign(target.global_position.x - global_position.x) as int
