# Shop UI Controller
extends CanvasLayer

@onready var shop_panel: Panel = $ShopPanel
@onready var items_container: VBoxContainer = $ShopPanel/MarginContainer/VBoxContainer/ScrollContainer/ItemsContainer
@onready var coins_label: Label = $ShopPanel/MarginContainer/VBoxContainer/CoinsLabel
@onready var close_button: Button = $ShopPanel/MarginContainer/VBoxContainer/CloseButton

var shop_system: Node


func _ready() -> void:
	shop_panel.visible = false
	close_button.pressed.connect(_on_close_pressed)
	
	# Load shop system
	var ShopSystem = load("res://scripts/shop/shop_system.gd")
	shop_system = ShopSystem.new()
	add_child(shop_system)
	
	# Connect to shop opened event
	EventBus.shop_opened.connect(_on_shop_opened)
	EventBus.item_purchased.connect(_on_item_purchased)


func _on_shop_opened(_shop_type: String) -> void:
	_populate_shop()
	_update_coins_display()
	shop_panel.visible = true
	get_tree().paused = true


func _populate_shop() -> void:
	# Clear existing items
	for child in items_container.get_children():
		child.queue_free()
	
	# Add shop items
	for item_id in shop_system.SHOP_ITEMS.keys():
		var item_data = shop_system.SHOP_ITEMS[item_id]
		var item_button = _create_item_button(item_id, item_data)
		items_container.add_child(item_button)


func _create_item_button(item_id: String, item_data: Dictionary) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 60)
	button.text = "%s - %d coins\n%s" % [
		item_data["name"],
		item_data["cost"],
		item_data["description"]
	]
	button.pressed.connect(_on_item_button_pressed.bind(item_id))
	return button


func _on_item_button_pressed(item_id: String) -> void:
	if shop_system.purchase_item(item_id):
		_update_coins_display()


func _on_item_purchased(_item_id: String, _cost: int) -> void:
	_update_coins_display()


func _update_coins_display() -> void:
	coins_label.text = "Blood Coins: " + str(GameManager.player_data.blood_coins)


func _on_close_pressed() -> void:
	shop_panel.visible = false
	get_tree().paused = false
