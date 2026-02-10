# Blood Coin Pickup
extends Area2D

@export var coin_value: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var collect_sound: AudioStreamPlayer2D = $CollectSound


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Simple bounce animation
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position:y", -8, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", 0, 0.5).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_collect(body)


func _collect(_player: Node2D) -> void:
	# Add coins to player
	GameManager.player_data.blood_coins += coin_value
	
	# Emit event
	EventBus.show_notification.emit("+" + str(coin_value) + " Blood Coins", 1.5)
	
	# Visual feedback
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(sprite, "position:y", -30, 0.3)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	queue_free()
