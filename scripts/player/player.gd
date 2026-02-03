# Player Controller - Main player script with souls-like combat
extends CharacterBody2D

# ====================
# SIGNALS
# ====================
signal attack_started(attack_type: String)
signal attack_ended
signal dodge_started
signal dodge_ended
signal damaged(amount: float)
signal died

# ====================
# COMPONENTS (assigned in scene)
# ====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var health_component: HealthComponent = $HealthComponent
@onready var stamina_component: StaminaComponent = $StaminaComponent
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var hitbox_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var attack_buffer_timer: Timer = $AttackBufferTimer

# ====================
# STATS
# ====================
var stats: PlayerStats = PlayerStats.new()

# ====================
# STATE VARIABLES
# ====================
var facing_direction: int = 1  # 1 = right, -1 = left
var is_attacking: bool = false
var is_dodging: bool = false
var is_invincible: bool = false
var combo_count: int = 0
var can_combo: bool = false
var attack_buffered: bool = false
var was_on_floor: bool = false

# Movement
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var input_direction: Vector2 = Vector2.ZERO

# Dodge
var dodge_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	_initialize_components()
	_connect_signals()
	_apply_game_manager_stats()


func _initialize_components() -> void:
	# Set up health
	health_component.max_health = stats.max_hp
	health_component.current_health = stats.max_hp
	
	# Set up stamina
	stamina_component.max_stamina = stats.max_stamina
	stamina_component.regen_rate = GameConstants.STAMINA_REGEN_RATE
	stamina_component.regen_delay = GameConstants.STAMINA_REGEN_DELAY
	
	# Set up hitbox
	hitbox.owner_entity = self
	hitbox.damage = stats.light_attack_damage
	
	# Set up hurtbox
	hurtbox.owner_entity = self


func _connect_signals() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	hurtbox.damage_received.connect(_on_damage_received)
	stamina_component.stamina_changed.connect(_on_stamina_changed)


func _apply_game_manager_stats() -> void:
	# Apply stats from GameManager (loaded save or upgrades)
	stats.max_hp = GameManager.player_data.max_hp
	stats.max_stamina = GameManager.player_data.max_stamina
	stats.attack_power = GameManager.player_data.attack_power
	stats.defense = GameManager.player_data.defense
	
	# Apply upgrades
	stats.apply_upgrades(GameManager.player_data.purchased_upgrades)
	
	# Re-initialize with new stats
	health_component.set_max_health(stats.max_hp, true)
	stamina_component.max_stamina = stats.max_stamina
	stamina_component.reset()


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Track floor state for coyote time
	if is_on_floor():
		was_on_floor = true
	elif was_on_floor:
		was_on_floor = false
		coyote_timer.start()
	
	move_and_slide()

# ====================
# INPUT HANDLING
# ====================
func get_input_direction() -> Vector2:
	input_direction = Vector2.ZERO
	input_direction.x = Input.get_axis("move_left", "move_right")
	input_direction.y = Input.get_axis("move_up", "move_down")
	return input_direction


func update_facing_direction() -> void:
	if input_direction.x != 0:
		facing_direction = sign(input_direction.x) as int
		sprite.flip_h = facing_direction < 0
		# Flip hitbox position based on direction
		hitbox_collision.position.x = abs(hitbox_collision.position.x) * facing_direction

# ====================
# MOVEMENT
# ====================
func move(speed: float) -> void:
	velocity.x = input_direction.x * speed


func stop_horizontal() -> void:
	velocity.x = move_toward(velocity.x, 0, stats.move_speed * 0.2)


func jump() -> void:
	if (is_on_floor() or not coyote_timer.is_stopped()) and stamina_component.use_stamina(10.0):
		velocity.y = stats.jump_velocity
		coyote_timer.stop()

# ====================
# COMBAT
# ====================
func light_attack() -> void:
	if is_attacking and can_combo and combo_count < 3:
		attack_buffered = true
		return
	
	if is_attacking or is_dodging:
		return
	
	if not stamina_component.use_stamina(stats.light_attack_stamina_cost):
		return
	
	is_attacking = true
	combo_count += 1
	hitbox.damage = stats.light_attack_damage + stats.attack_power
	
	# Check for critical hit
	if randf() < stats.critical_chance:
		hitbox.damage *= stats.critical_multiplier
		EventBus.critical_hit.emit(self, hitbox.damage)
	
	attack_started.emit("light_" + str(combo_count))


func heavy_attack() -> void:
	if is_attacking or is_dodging:
		return
	
	if not stamina_component.use_stamina(stats.heavy_attack_stamina_cost):
		return
	
	is_attacking = true
	combo_count = 0
	hitbox.damage = stats.heavy_attack_damage + stats.attack_power * 1.5
	
	# Check for critical hit
	if randf() < stats.critical_chance:
		hitbox.damage *= stats.critical_multiplier
		EventBus.critical_hit.emit(self, hitbox.damage)
	
	attack_started.emit("heavy")


func end_attack() -> void:
	is_attacking = false
	hitbox.disable()
	attack_ended.emit()
	
	if attack_buffered:
		attack_buffered = false
		light_attack()
	else:
		can_combo = true
		attack_buffer_timer.start()


func _on_attack_buffer_timeout() -> void:
	can_combo = false
	combo_count = 0


func enable_hitbox() -> void:
	hitbox.enable()


func disable_hitbox() -> void:
	hitbox.disable()

# ====================
# DODGE
# ====================
func dodge() -> void:
	if is_dodging or is_attacking:
		return
	
	if not stamina_component.use_stamina(stats.dodge_stamina_cost):
		return
	
	is_dodging = true
	is_invincible = true
	hurtbox.set_invincible(stats.invincibility_duration)
	
	# Dodge in input direction or facing direction
	if input_direction.length() > 0:
		dodge_direction = input_direction.normalized()
	else:
		dodge_direction = Vector2(facing_direction, 0)
	
	dodge_started.emit()


func end_dodge() -> void:
	is_dodging = false
	is_invincible = false
	dodge_ended.emit()

# ====================
# DAMAGE
# ====================
func _on_damage_received(amount: float, knockback: Vector2, _damage_type: int, attacker: Node2D) -> void:
	if is_invincible:
		return
	
	# Apply defense reduction
	var actual_damage = max(1, amount - stats.defense)
	
	health_component.take_damage(actual_damage, attacker)
	
	# Apply knockback
	velocity += knockback
	
	# Brief invincibility after taking damage
	hurtbox.set_invincible(GameConstants.INVINCIBILITY_AFTER_HIT)
	is_invincible = true
	
	# Create timer to reset invincibility
	await get_tree().create_timer(GameConstants.INVINCIBILITY_AFTER_HIT).timeout
	is_invincible = false
	
	damaged.emit(actual_damage)
	EventBus.player_took_damage.emit(actual_damage, attacker)


func _on_health_changed(current: float, max_health: float) -> void:
	EventBus.player_health_changed.emit(current, max_health)
	
	# Sync with GameManager
	GameManager.player_data.current_hp = current


func _on_stamina_changed(current: float, max_stamina: float) -> void:
	EventBus.player_stamina_changed.emit(current, max_stamina)


func _on_died() -> void:
	died.emit()
	EventBus.player_died.emit(self)
	
	# Trigger death sequence
	state_machine.change_state(&"Death")
