# The Fallen Templar - First Boss
# A corrupted knight with sword and shield, 3 phases
extends BaseBoss
class_name FallenTemplar

# ====================
# ADDITIONAL COMPONENTS
# ====================
@onready var sword_hitbox: Hitbox = $SwordHitbox
@onready var shield_hitbox: Hitbox = $ShieldHitbox
@onready var ground_slam_area: Area2D = $GroundSlamArea
@onready var holy_projectile_spawn: Marker2D = $HolyProjectileSpawn

# Preloads
var holy_projectile_scene: PackedScene = null

# Phase-specific variables
var enrage_mode: bool = false
var attack_speed_multiplier: float = 1.0


func _ready() -> void:
	boss_name = "THE FALLEN TEMPLAR"
	boss_title = "Guardian of the Forsaken Gate"
	max_hp = 500.0
	phase_thresholds = [0.6, 0.3]  # Phase 2 at 60%, Phase 3 at 30%
	soul_essence_reward = 1
	blood_coin_reward = 150
	
	# Load projectile scene if exists
	if ResourceLoader.exists("res://scenes/bosses/projectiles/holy_projectile.tscn"):
		holy_projectile_scene = load("res://scenes/bosses/projectiles/holy_projectile.tscn")
	
	super._ready()
	_setup_hitboxes()


func _setup_hitboxes() -> void:
	if sword_hitbox:
		sword_hitbox.owner_entity = self
	if shield_hitbox:
		shield_hitbox.owner_entity = self


func _setup_phases() -> void:
	_update_attack_patterns_for_phase()


func _update_attack_patterns_for_phase() -> void:
	attack_patterns.clear()
	current_attack_index = 0
	
	match current_phase:
		0:  # Phase 1 - Basic attacks
			attack_patterns = _get_phase_1_attacks()
		1:  # Phase 2 - Add holy attacks
			attack_patterns = _get_phase_2_attacks()
			attack_speed_multiplier = 1.2
		2:  # Phase 3 - Enrage mode
			attack_patterns = _get_phase_3_attacks()
			attack_speed_multiplier = 1.5
			enrage_mode = true
	
	# Shuffle for variety
	attack_patterns.shuffle()


# ====================
# PHASE 1 ATTACKS
# ====================
func _get_phase_1_attacks() -> Array[Dictionary]:
	return [
		# Sword Slash - Basic horizontal slash
		{
			"name": "sword_slash",
			"type": "melee",
			"animation": "attack_slash",
			"damage": 20.0,
			"telegraph": 0.4,
			"duration": 0.5,
			"recovery": 0.3,
			"hitboxes": ["SwordHitbox"],
			"hitbox": {"start": 0.15, "end": 0.35},
			"movement": {"lunge": 100}
		},
		# Overhead Strike - Slow but heavy
		{
			"name": "overhead_strike",
			"type": "melee",
			"animation": "attack_overhead",
			"damage": 35.0,
			"telegraph": 0.7,
			"duration": 0.6,
			"recovery": 0.5,
			"hitboxes": ["SwordHitbox"],
			"hitbox": {"start": 0.3, "end": 0.45},
			"movement": {"lunge": 50}
		},
		# Shield Bash - Quick stun attack
		{
			"name": "shield_bash",
			"type": "melee",
			"animation": "attack_shield",
			"damage": 15.0,
			"telegraph": 0.3,
			"duration": 0.4,
			"recovery": 0.2,
			"hitboxes": ["ShieldHitbox"],
			"hitbox": {"start": 0.1, "end": 0.25},
			"movement": {"lunge": 150}
		},
		# Charge Attack - Rush forward with shield
		{
			"name": "charge",
			"type": "melee",
			"animation": "attack_charge",
			"damage": 25.0,
			"telegraph": 0.6,
			"duration": 0.8,
			"recovery": 0.6,
			"hitboxes": ["ShieldHitbox"],
			"hitbox": {"start": 0.1, "end": 0.7},
			"movement": {"lunge": 300}
		},
		# Double Slash - Two quick slashes
		{
			"name": "double_slash",
			"type": "combo",
			"animation": "attack_combo",
			"damage": 15.0,
			"telegraph": 0.35,
			"duration": 0.7,
			"recovery": 0.4,
			"hitboxes": ["SwordHitbox"],
			"hitbox": {"start": 0.1, "end": 0.6},
			"movement": {"lunge": 80}
		}
	]


# ====================
# PHASE 2 ATTACKS (+ Phase 1)
# ====================
func _get_phase_2_attacks() -> Array[Dictionary]:
	var attacks = _get_phase_1_attacks()
	
	# Add holy-themed attacks
	attacks.append_array([
		# Holy Smite - Ground AoE attack
		{
			"name": "holy_smite",
			"type": "aoe",
			"animation": "attack_smite",
			"damage": 30.0,
			"telegraph": 0.8,
			"duration": 0.6,
			"recovery": 0.5,
			"hitboxes": ["GroundSlamArea"],
			"hitbox": {"start": 0.2, "end": 0.4},
			"movement": {}
		},
		# Divine Wrath - Projectile attack
		{
			"name": "divine_wrath",
			"type": "ranged",
			"animation": "attack_projectile",
			"damage": 20.0,
			"telegraph": 0.5,
			"duration": 0.5,
			"recovery": 0.4,
			"movement": {}
		},
		# Rising Slash - Anti-air attack
		{
			"name": "rising_slash",
			"type": "melee",
			"animation": "attack_rising",
			"damage": 25.0,
			"telegraph": 0.4,
			"duration": 0.5,
			"recovery": 0.5,
			"hitboxes": ["SwordHitbox"],
			"hitbox": {"start": 0.1, "end": 0.4},
			"movement": {"lunge": 50}
		},
		# Shield Wall - Defensive stance then counter
		{
			"name": "shield_wall",
			"type": "special",
			"animation": "shield_stance",
			"damage": 30.0,
			"telegraph": 0.3,
			"duration": 1.0,
			"recovery": 0.3,
			"hitboxes": ["ShieldHitbox", "SwordHitbox"],
			"hitbox": {"start": 0.8, "end": 0.95},
			"movement": {"lunge": 120}
		}
	])
	
	return attacks


# ====================
# PHASE 3 ATTACKS (Enrage + New Combos)
# ====================
func _get_phase_3_attacks() -> Array[Dictionary]:
	var attacks = _get_phase_2_attacks()
	
	# Add enrage-only attacks
	attacks.append_array([
		# Berserk Combo - 4-hit combo
		{
			"name": "berserk_combo",
			"type": "combo",
			"animation": "attack_berserk",
			"damage": 18.0,
			"telegraph": 0.3,
			"duration": 1.2,
			"recovery": 0.6,
			"hitboxes": ["SwordHitbox"],
			"hitbox": {"start": 0.1, "end": 1.0},
			"movement": {"lunge": 150}
		},
		# Divine Judgment - Full arena attack
		{
			"name": "divine_judgment",
			"type": "aoe",
			"animation": "attack_judgment",
			"damage": 40.0,
			"telegraph": 1.2,
			"duration": 0.8,
			"recovery": 0.8,
			"hitboxes": ["GroundSlamArea"],
			"hitbox": {"start": 0.3, "end": 0.6},
			"movement": {}
		},
		# Resurrection Attempt - Heal attempt (can be interrupted)
		{
			"name": "resurrection",
			"type": "special",
			"animation": "resurrection",
			"damage": 0.0,
			"telegraph": 1.5,
			"duration": 2.0,
			"recovery": 0.5,
			"movement": {}
		},
		# Triple Projectile
		{
			"name": "triple_wrath",
			"type": "ranged",
			"animation": "attack_triple_projectile",
			"damage": 15.0,
			"telegraph": 0.6,
			"duration": 0.8,
			"recovery": 0.5,
			"movement": {}
		}
	])
	
	return attacks


# ====================
# ATTACK IMPLEMENTATIONS
# ====================
func _execute_ranged_attack(attack_data: Dictionary) -> void:
	var attack_name = attack_data.get("name", "")
	
	match attack_name:
		"divine_wrath":
			_spawn_holy_projectile(1)
		"triple_wrath":
			_spawn_holy_projectile(3)


func _spawn_holy_projectile(count: int) -> void:
	if holy_projectile_scene == null:
		# Fallback: just create a simple projectile
		_create_simple_projectile(count)
		return
	
	for i in range(count):
		var projectile = holy_projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = holy_projectile_spawn.global_position
		
		var angle_offset = (i - count / 2.0) * 0.2
		var direction = Vector2(facing_direction, angle_offset).normalized()
		projectile.set_direction(direction)
		projectile.damage = base_attack_damage * 0.8


func _create_simple_projectile(count: int) -> void:
	# Simple projectile using Area2D
	for i in range(count):
		var projectile = Area2D.new()
		projectile.collision_layer = 8
		projectile.collision_mask = 4
		
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 10
		shape.shape = circle
		projectile.add_child(shape)
		
		var visual = ColorRect.new()
		visual.size = Vector2(20, 20)
		visual.position = Vector2(-10, -10)
		visual.color = Color(1, 0.8, 0.2, 0.9)
		projectile.add_child(visual)
		
		get_parent().add_child(projectile)
		projectile.global_position = global_position + Vector2(facing_direction * 30, -30)
		
		# Move projectile
		var angle_offset = (i - count / 2.0) * 0.3
		var direction = Vector2(facing_direction, angle_offset).normalized()
		
		var tween = projectile.create_tween()
		tween.tween_property(projectile, "position", projectile.position + direction * 500, 1.0)
		tween.tween_callback(projectile.queue_free)
		
		# Damage on contact
		projectile.body_entered.connect(func(body):
			if body.is_in_group("player") and body.has_node("Hurtbox"):
				var hurtbox = body.get_node("Hurtbox")
				hurtbox.take_damage(base_attack_damage * 0.8, direction * 100, 0, self)
			projectile.queue_free()
		)


func _execute_aoe_attack(attack_data: Dictionary) -> void:
	var attack_name = attack_data.get("name", "")
	
	# Create ground indicator
	var indicator = ColorRect.new()
	indicator.size = Vector2(200, 20)
	indicator.position = Vector2(-100, 0)
	indicator.color = Color(1, 0.3, 0.1, 0.5)
	add_child(indicator)
	
	# Pulse effect
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(indicator, "modulate:a", 0.2, 0.15)
	tween.tween_property(indicator, "modulate:a", 0.8, 0.15)
	
	await get_tree().create_timer(attack_data.get("telegraph", 0.8)).timeout
	indicator.queue_free()


func _execute_special_attack(attack_data: Dictionary) -> void:
	var attack_name = attack_data.get("name", "")
	
	match attack_name:
		"resurrection":
			_attempt_resurrection()
		"shield_wall":
			_perform_shield_wall()


func _attempt_resurrection() -> void:
	# Can be interrupted by attacking
	var heal_amount = max_hp * 0.1
	
	# Visual effect
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1.5, 1.2, 0.5), 1.0)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	
	await get_tree().create_timer(1.5).timeout
	
	# Only heal if not interrupted (not in hurt state)
	if not is_dead:
		health_component.heal(heal_amount)


func _perform_shield_wall() -> void:
	# Brief invincibility during stance
	is_invincible = true
	await get_tree().create_timer(0.8).timeout
	is_invincible = false
