# Player Stats Resource - Exportable player statistics
class_name PlayerStats
extends Resource

@export var max_hp: float = 100.0
@export var max_stamina: float = 100.0
@export var attack_power: float = 10.0
@export var defense: float = 5.0
@export var move_speed: float = 200.0
@export var run_speed: float = 320.0
@export var jump_velocity: float = -400.0

# Combat stats
@export var light_attack_damage: float = 15.0
@export var heavy_attack_damage: float = 35.0
@export var critical_chance: float = 0.1
@export var critical_multiplier: float = 1.5

# Stamina costs
@export var dodge_stamina_cost: float = 25.0
@export var light_attack_stamina_cost: float = 15.0
@export var heavy_attack_stamina_cost: float = 30.0

# Timings
@export var dodge_duration: float = 0.4
@export var dodge_speed: float = 400.0
@export var invincibility_duration: float = 0.35


func apply_upgrades(upgrades: Array) -> void:
	for upgrade_id in upgrades:
		match upgrade_id:
			"hp_1": max_hp += 20
			"hp_2": max_hp += 30
			"hp_3": max_hp += 50
			"stamina_1": max_stamina += 15
			"stamina_2": max_stamina += 25
			"attack_1": attack_power += 5
			"attack_2": attack_power += 10
			"defense_1": defense += 3
			"defense_2": defense += 6
			"speed_1": move_speed += 30
