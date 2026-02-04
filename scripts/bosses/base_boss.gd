# Base Boss - Multi-phase boss framework with complex attack patterns
class_name BaseBoss
extends CharacterBody2D

# ====================
# SIGNALS
# ====================
signal phase_changed(new_phase: int)
signal attack_started(attack_name: String)
signal attack_ended
signal defeated
signal telegraph_started(attack_name: String, duration: float)

# ====================
# EXPORTS
# ====================
@export_category("Boss Info")
@export var boss_name: String = "Boss"
@export var boss_title: String = "The Unknown"

@export_category("Boss Stats")
@export var max_hp: float = 500.0
@export var phase_thresholds: Array[float] = [0.6, 0.3]  # HP % for phase transitions
@export var soul_essence_reward: int = 1
@export var blood_coin_reward: int = 100

@export_category("Combat")
@export var base_attack_damage: float = 25.0
@export var telegraph_duration: float = 0.5

# ====================
# COMPONENTS
# ====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var attack_timer: Timer = $AttackTimer
@onready var telegraph_indicator: Node2D = $TelegraphIndicator

# ====================
# STATE VARIABLES
# ====================
var current_phase: int = 0  # 0 = Phase 1, 1 = Phase 2, etc.
var target: Node2D = null
var facing_direction: int = 1
var is_attacking: bool = false
var is_transitioning: bool = false
var is_invincible: bool = false
var is_dead: bool = false

# Attack pattern system
var attack_patterns: Array[Dictionary] = []
var current_attack_index: int = 0
var attacks_in_current_pattern: int = 0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready() -> void:
	add_to_group("boss")
	_load_sprites()
	_setup_phases()
	_initialize_components()
	_connect_signals()
	EventBus.boss_spawned.emit(self)


func _load_sprites() -> void:
	# Override in child classes for specific sprites
	# Default: try to load boss sprites
	if sprite and ResourceLoader.exists("res://assets/sprites/bosses/fallen_templar_boss_1770125098193.png"):
		SpriteLoader.setup_boss_sprite_frames(sprite)


func _setup_phases() -> void:
	# Override in child classes to define attack patterns per phase
	pass


func _initialize_components() -> void:
	health_component.max_health = max_hp
	health_component.current_health = max_hp
	
	hurtbox.owner_entity = self


func _connect_signals() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	hurtbox.damage_received.connect(_on_damage_received)
	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

# ====================
# PHASE SYSTEM
# ====================
func check_phase_transition() -> void:
	if is_transitioning or is_dead:
		return
	
	var hp_percent = health_component.get_health_percent()
	
	for i in range(phase_thresholds.size()):
		if current_phase <= i and hp_percent <= phase_thresholds[i]:
			transition_to_phase(i + 1)
			break


func transition_to_phase(new_phase: int) -> void:
	is_transitioning = true
	is_invincible = true
	current_phase = new_phase
	
	# Play phase transition
	state_machine.change_state(&"PhaseTransition")
	
	phase_changed.emit(new_phase)
	EventBus.boss_phase_changed.emit(self, new_phase)


func end_phase_transition() -> void:
	is_transitioning = false
	is_invincible = false
	_update_attack_patterns_for_phase()

# ====================
# ATTACK PATTERN SYSTEM
# ====================
func _update_attack_patterns_for_phase() -> void:
	# Override in child classes
	pass


func get_next_attack() -> Dictionary:
	if attack_patterns.is_empty():
		return {}
	
	var attack = attack_patterns[current_attack_index]
	current_attack_index = (current_attack_index + 1) % attack_patterns.size()
	attacks_in_current_pattern += 1
	
	return attack


func execute_attack(attack_data: Dictionary) -> void:
	if attack_data.is_empty():
		return
	
	is_attacking = true
	var attack_name = attack_data.get("name", "attack")
	var telegraph_time = attack_data.get("telegraph", telegraph_duration)
	
	# Telegraph the attack
	if telegraph_time > 0:
		_show_telegraph(attack_name, telegraph_time)
		await get_tree().create_timer(telegraph_time).timeout
	
	attack_started.emit(attack_name)
	
	# Execute based on attack type
	match attack_data.get("type", "melee"):
		"melee":
			_execute_melee_attack(attack_data)
		"ranged":
			_execute_ranged_attack(attack_data)
		"aoe":
			_execute_aoe_attack(attack_data)
		"combo":
			_execute_combo_attack(attack_data)
		"special":
			_execute_special_attack(attack_data)


func _show_telegraph(attack_name: String, duration: float) -> void:
	telegraph_started.emit(attack_name, duration)
	
	if telegraph_indicator:
		telegraph_indicator.visible = true
		# Flash effect
		var tween = create_tween()
		tween.set_loops(int(duration / 0.2))
		tween.tween_property(telegraph_indicator, "modulate:a", 0.3, 0.1)
		tween.tween_property(telegraph_indicator, "modulate:a", 1.0, 0.1)


func _hide_telegraph() -> void:
	if telegraph_indicator:
		telegraph_indicator.visible = false


func _execute_melee_attack(attack_data: Dictionary) -> void:
	# Override in child classes
	pass


func _execute_ranged_attack(attack_data: Dictionary) -> void:
	# Override in child classes
	pass


func _execute_aoe_attack(attack_data: Dictionary) -> void:
	# Override in child classes
	pass


func _execute_combo_attack(attack_data: Dictionary) -> void:
	# Override in child classes
	pass


func _execute_special_attack(attack_data: Dictionary) -> void:
	# Override in child classes
	pass


func end_attack() -> void:
	is_attacking = false
	_hide_telegraph()
	attack_ended.emit()
	
	# Schedule next attack
	var cooldown = randf_range(1.0, 2.5)
	attack_timer.start(cooldown)


func _on_attack_timer_timeout() -> void:
	if not is_dead and not is_transitioning and target:
		var next_attack = get_next_attack()
		if not next_attack.is_empty():
			execute_attack(next_attack)

# ====================
# TARGET & MOVEMENT
# ====================
func set_target(new_target: Node2D) -> void:
	target = new_target


func update_facing() -> void:
	if target:
		var direction = sign(target.global_position.x - global_position.x)
		if direction != 0:
			facing_direction = direction as int
			sprite.flip_h = facing_direction < 0


func move_towards_target(speed: float) -> void:
	if target:
		var direction = sign(target.global_position.x - global_position.x)
		velocity.x = direction * speed
		update_facing()


func stop_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, 500)


func get_distance_to_target() -> float:
	if target:
		return global_position.distance_to(target.global_position)
	return INF

# ====================
# DAMAGE
# ====================
func _on_damage_received(amount: float, knockback: Vector2, _damage_type: int, attacker: Node2D) -> void:
	if is_invincible or is_dead:
		return
	
	health_component.take_damage(amount, attacker)
	
	# Bosses have reduced knockback
	velocity += knockback * 0.2
	
	# Visual feedback
	_flash_damage()
	
	# Check for phase transition
	check_phase_transition()


func _flash_damage() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.5), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)


func _on_health_changed(current: float, max_health: float) -> void:
	EventBus.boss_health_changed.emit(current, max_health)


func _on_died() -> void:
	if is_dead:
		return
	
	is_dead = true
	is_invincible = true
	
	# Give rewards
	GameManager.add_blood_coins(blood_coin_reward)
	GameManager.add_soul_essence(soul_essence_reward)
	
	defeated.emit()
	EventBus.boss_defeated.emit(self)
	EventBus.boss_killed.emit(self, blood_coin_reward)
	
	state_machine.change_state(&"Defeated")

# ====================
# UTILITY
# ====================
func get_boss_name() -> String:
	return boss_name


func get_full_title() -> String:
	return "%s, %s" % [boss_name, boss_title]
