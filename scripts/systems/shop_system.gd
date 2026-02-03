# Shop System - Handles buying and selling items
class_name ShopSystem
extends Node

signal item_purchased(item_id: String, cost: int)
signal item_sold(item_id: String, value: int)
signal insufficient_funds

# Item database
var shop_items: Dictionary = {
	# Consumables
	"health_potion": {
		"name": "Health Potion",
		"description": "Restores 30 HP",
		"cost": 50,
		"type": "consumable",
		"effect": {"heal": 30}
	},
	"stamina_elixir": {
		"name": "Stamina Elixir",
		"description": "Restores 50 Stamina instantly",
		"cost": 40,
		"type": "consumable",
		"effect": {"stamina": 50}
	},
	"holy_water": {
		"name": "Holy Water",
		"description": "Deals 50 damage to undead enemies",
		"cost": 75,
		"type": "consumable",
		"effect": {"damage_undead": 50}
	},
	
	# Weapons (placeholders for weapon system)
	"rusty_sword": {
		"name": "Rusty Sword",
		"description": "+5 Attack Power",
		"cost": 100,
		"type": "weapon",
		"effect": {"attack_power": 5}
	},
	"knight_sword": {
		"name": "Knight's Sword",
		"description": "+15 Attack Power",
		"cost": 300,
		"type": "weapon",
		"effect": {"attack_power": 15}
	},
	"blood_blade": {
		"name": "Blood Blade",
		"description": "+25 Attack, Lifesteal 5%",
		"cost": 500,
		"type": "weapon",
		"effect": {"attack_power": 25, "lifesteal": 0.05}
	},
	
	# Armor
	"leather_armor": {
		"name": "Leather Armor",
		"description": "+5 Defense",
		"cost": 80,
		"type": "armor",
		"effect": {"defense": 5}
	},
	"chain_mail": {
		"name": "Chain Mail",
		"description": "+12 Defense",
		"cost": 250,
		"type": "armor",
		"effect": {"defense": 12}
	},
	"templar_armor": {
		"name": "Templar Armor",
		"description": "+20 Defense, +10 HP",
		"cost": 500,
		"type": "armor",
		"effect": {"defense": 20, "max_hp": 10}
	}
}

# Upgrade items (purchased with Soul Essence)
var upgrade_items: Dictionary = {
	"hp_1": {
		"name": "Vitality I",
		"description": "+20 Max HP",
		"cost": 1,
		"effect": {"max_hp": 20}
	},
	"hp_2": {
		"name": "Vitality II",
		"description": "+30 Max HP",
		"cost": 2,
		"prerequisites": ["hp_1"],
		"effect": {"max_hp": 30}
	},
	"hp_3": {
		"name": "Vitality III",
		"description": "+50 Max HP",
		"cost": 3,
		"prerequisites": ["hp_2"],
		"effect": {"max_hp": 50}
	},
	"stamina_1": {
		"name": "Endurance I",
		"description": "+15 Max Stamina",
		"cost": 1,
		"effect": {"max_stamina": 15}
	},
	"stamina_2": {
		"name": "Endurance II",
		"description": "+25 Max Stamina",
		"cost": 2,
		"prerequisites": ["stamina_1"],
		"effect": {"max_stamina": 25}
	},
	"attack_1": {
		"name": "Strength I",
		"description": "+5 Attack Power",
		"cost": 1,
		"effect": {"attack_power": 5}
	},
	"attack_2": {
		"name": "Strength II",
		"description": "+10 Attack Power",
		"cost": 2,
		"prerequisites": ["attack_1"],
		"effect": {"attack_power": 10}
	},
	"defense_1": {
		"name": "Fortitude I",
		"description": "+3 Defense",
		"cost": 1,
		"effect": {"defense": 3}
	},
	"defense_2": {
		"name": "Fortitude II",
		"description": "+6 Defense",
		"cost": 2,
		"prerequisites": ["defense_1"],
		"effect": {"defense": 6}
	},
	"speed_1": {
		"name": "Agility I",
		"description": "+30 Move Speed",
		"cost": 1,
		"effect": {"move_speed": 30}
	}
}


func buy_item(item_id: String) -> bool:
	if not shop_items.has(item_id):
		return false
	
	var item = shop_items[item_id]
	var cost = item.cost
	
	if not GameManager.spend_blood_coins(cost):
		insufficient_funds.emit()
		return false
	
	# Add to inventory
	GameManager.player_data.inventory.append(item_id)
	item_purchased.emit(item_id, cost)
	EventBus.item_purchased.emit(item_id, cost)
	
	return true


func sell_item(item_id: String) -> bool:
	var inventory = GameManager.player_data.inventory
	var index = inventory.find(item_id)
	
	if index == -1:
		return false
	
	# Calculate sell value (50% of cost)
	var value = 0
	if shop_items.has(item_id):
		value = int(shop_items[item_id].cost * 0.5)
	
	inventory.remove_at(index)
	GameManager.add_blood_coins(value)
	
	item_sold.emit(item_id, value)
	EventBus.item_sold.emit(item_id, value)
	
	return true


func buy_upgrade(upgrade_id: String) -> bool:
	if not upgrade_items.has(upgrade_id):
		return false
	
	# Check if already purchased
	if upgrade_id in GameManager.player_data.purchased_upgrades:
		return false
	
	var upgrade = upgrade_items[upgrade_id]
	
	# Check prerequisites
	if upgrade.has("prerequisites"):
		for prereq in upgrade.prerequisites:
			if not prereq in GameManager.player_data.purchased_upgrades:
				return false
	
	# Check cost (Soul Essence)
	if not GameManager.spend_soul_essence(upgrade.cost):
		insufficient_funds.emit()
		return false
	
	# Apply upgrade
	GameManager.player_data.purchased_upgrades.append(upgrade_id)
	_apply_upgrade_effect(upgrade.effect)
	
	EventBus.upgrade_purchased.emit(upgrade_id)
	
	return true


func _apply_upgrade_effect(effect: Dictionary) -> void:
	for stat in effect:
		match stat:
			"max_hp":
				GameManager.player_data.max_hp += effect.max_hp
			"max_stamina":
				GameManager.player_data.max_stamina += effect.max_stamina
			"attack_power":
				GameManager.player_data.attack_power += effect.attack_power
			"defense":
				GameManager.player_data.defense += effect.defense


func get_available_upgrades() -> Array[String]:
	var available: Array[String] = []
	
	for upgrade_id in upgrade_items:
		if upgrade_id in GameManager.player_data.purchased_upgrades:
			continue
		
		var upgrade = upgrade_items[upgrade_id]
		var can_purchase = true
		
		if upgrade.has("prerequisites"):
			for prereq in upgrade.prerequisites:
				if not prereq in GameManager.player_data.purchased_upgrades:
					can_purchase = false
					break
		
		if can_purchase:
			available.append(upgrade_id)
	
	return available
