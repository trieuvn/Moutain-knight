# Shop System - Manages item purchases
extends Node

# Shop items database
const SHOP_ITEMS = {
	"health_potion": {
		"name": "Health Potion",
		"description": "Restores 50 HP",
		"cost": 50,
		"type": "consumable"
	},
	"stamina_potion": {
		"name": "Stamina Potion",
		"description": "Restores 50 Stamina",
		"cost": 40,
		"type": "consumable"
	},
	"max_hp_upgrade": {
		"name": "Max HP +20",
		"description": "Permanently increase max HP",
		"cost": 200,
		"type": "upgrade"
	},
	"max_stamina_upgrade": {
		"name": "Max Stamina +20",
		"description": "Permanently increase max stamina",
		"cost": 150,
		"type": "upgrade"
	},
	"attack_upgrade": {
		"name": "Attack Damage +5",
		"description": "Increase attack damage",
		"cost": 100,
		"type": "upgrade"
	}
}


func purchase_item(item_id: String) -> bool:
	if not SHOP_ITEMS.has(item_id):
		return false
	
	var item = SHOP_ITEMS[item_id]
	var cost = item["cost"]
	
	# Check if player has enough coins
	if GameManager.player_data.blood_coins < cost:
		EventBus.show_notification.emit("Not enough Blood Coins!", 2.0)
		return false
	
	# Deduct coins
	GameManager.player_data.blood_coins -= cost
	
	# Apply item effect
	match item["type"]:
		"consumable":
			_apply_consumable(item_id)
		"upgrade":
			_apply_upgrade(item_id)
	
	EventBus.item_purchased.emit(item_id, cost)
	EventBus.show_notification.emit("Purchased: " + item["name"], 2.0)
	return true


func _apply_consumable(item_id: String) -> void:
	match item_id:
		"health_potion":
			GameManager.player_data.current_hp = min(
				GameManager.player_data.current_hp + 50,
				GameManager.player_data.max_hp
			)
			EventBus.player_health_changed.emit(
				GameManager.player_data.current_hp,
				GameManager.player_data.max_hp
			)
		"stamina_potion":
			# Stamina restored on use (handled in player script)
			pass


func _apply_upgrade(item_id: String) -> void:
	match item_id:
		"max_hp_upgrade":
			GameManager.player_data.max_hp += 20
			GameManager.player_data.current_hp += 20
			EventBus.player_health_changed.emit(
				GameManager.player_data.current_hp,
				GameManager.player_data.max_hp
			)
		"max_stamina_upgrade":
			GameManager.player_data.max_stamina += 20
		"attack_upgrade":
			GameManager.player_data.light_attack_damage += 5
			GameManager.player_data.heavy_attack_damage += 10
