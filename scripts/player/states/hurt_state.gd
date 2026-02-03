# Player Hurt State
extends State

@onready var player: CharacterBody2D = owner
var stagger_timer: float = 0.0


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.sprite.play("hurt")
	stagger_timer = GameConstants.STAGGER_DURATION
	
	# Flash effect
	_flash_sprite()


func exit() -> void:
	super.exit()
	player.sprite.modulate = Color.WHITE


func physics_update(delta: float) -> void:
	stagger_timer -= delta
	
	# Decelerate from knockback
	player.velocity.x = move_toward(player.velocity.x, 0, 600 * delta)
	
	if stagger_timer <= 0:
		if player.is_on_floor():
			state_machine.change_state(&"Idle")
		else:
			state_machine.change_state(&"Fall")


func _flash_sprite() -> void:
	var tween = player.create_tween()
	tween.tween_property(player.sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(player.sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(player.sprite, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(player.sprite, "modulate", Color.WHITE, 0.1)


func handle_input(_event: InputEvent) -> void:
	# Cannot act while staggered
	pass
