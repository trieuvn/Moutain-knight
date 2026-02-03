# HUD Controller - Manages health, stamina, and currency display
extends CanvasLayer

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HealthContainer/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthContainer/HealthLabel
@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaContainer/StaminaBar
@onready var blood_coins_label: Label = $MarginContainer/VBoxContainer/CurrencyContainer/BloodCoins/Amount
@onready var soul_essence_label: Label = $MarginContainer/VBoxContainer/CurrencyContainer/SoulEssence/Amount
@onready var boss_health_container: VBoxContainer = $BossHealthContainer
@onready var boss_name_label: Label = $BossHealthContainer/BossName
@onready var boss_health_bar: ProgressBar = $BossHealthContainer/BossHealthBar


func _ready() -> void:
	_connect_signals()
	_update_currency()
	
	# Style the health bar
	_style_health_bar()
	_style_stamina_bar()
	_style_boss_health_bar()


func _connect_signals() -> void:
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_stamina_changed.connect(_on_player_stamina_changed)
	EventBus.update_hud.connect(_update_currency)
	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.boss_health_changed.connect(_on_boss_health_changed)
	EventBus.boss_defeated.connect(_on_boss_defeated)


func _style_health_bar() -> void:
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.05, 0.05, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	health_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.7, 0.1, 0.1, 1.0)
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	health_bar.add_theme_stylebox_override("fill", fill_style)


func _style_stamina_bar() -> void:
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.12, 0.05, 0.8)
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	stamina_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.85, 0.7, 0.2, 1.0)
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3
	stamina_bar.add_theme_stylebox_override("fill", fill_style)


func _style_boss_health_bar() -> void:
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.05, 0.15, 0.9)
	bg_style.corner_radius_top_left = 5
	bg_style.corner_radius_top_right = 5
	bg_style.corner_radius_bottom_left = 5
	bg_style.corner_radius_bottom_right = 5
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.3, 0.1, 0.3, 1.0)
	boss_health_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.6, 0.1, 0.4, 1.0)
	fill_style.corner_radius_top_left = 5
	fill_style.corner_radius_top_right = 5
	fill_style.corner_radius_bottom_left = 5
	fill_style.corner_radius_bottom_right = 5
	boss_health_bar.add_theme_stylebox_override("fill", fill_style)


func _on_player_health_changed(current: float, max_health: float) -> void:
	health_bar.max_value = max_health
	
	# Animate health change
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current, 0.2)
	
	health_label.text = "%d/%d" % [int(current), int(max_health)]
	
	# Flash red when taking damage
	if current < health_bar.value:
		_flash_bar(health_bar, Color(1, 0.3, 0.3))


func _on_player_stamina_changed(current: float, max_stamina: float) -> void:
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current


func _update_currency() -> void:
	blood_coins_label.text = str(GameManager.player_data.blood_coins)
	soul_essence_label.text = str(GameManager.player_data.soul_essence)


func _on_boss_spawned(boss: Node2D) -> void:
	boss_health_container.visible = true
	if boss.has_method("get_boss_name"):
		boss_name_label.text = boss.get_boss_name()
	else:
		boss_name_label.text = "BOSS"


func _on_boss_health_changed(current: float, max_health: float) -> void:
	boss_health_bar.max_value = max_health
	
	var tween = create_tween()
	tween.tween_property(boss_health_bar, "value", current, 0.3)


func _on_boss_defeated(_boss: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(boss_health_container, "modulate:a", 0.0, 1.0)
	await tween.finished
	boss_health_container.visible = false
	boss_health_container.modulate.a = 1.0


func _flash_bar(bar: ProgressBar, color: Color) -> void:
	var original_color = bar.get_theme_stylebox("fill").bg_color
	var tween = create_tween()
	tween.tween_property(bar, "modulate", color, 0.05)
	tween.tween_property(bar, "modulate", Color.WHITE, 0.15)
