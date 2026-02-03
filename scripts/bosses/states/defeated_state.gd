# Boss Defeated State
extends State

@onready var boss: BaseBoss = owner


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	boss.sprite.play("death")
	boss.velocity = Vector2.ZERO
	
	# Disable all hitboxes
	for child in boss.get_children():
		if child is Hitbox:
			child.disable()
		if child is Hurtbox:
			child.monitoring = false
	
	# Play death sequence
	await _death_sequence()


func _death_sequence() -> void:
	# Dramatic death with flashes
	var tween = boss.create_tween()
	
	for i in range(5):
		tween.tween_property(boss.sprite, "modulate", Color(2, 2, 2), 0.1)
		tween.tween_property(boss.sprite, "modulate", Color.WHITE, 0.15)
		tween.tween_interval(0.1)
	
	await tween.finished
	await boss.get_tree().create_timer(1.0).timeout
	
	# Fade out
	var fade_tween = boss.create_tween()
	fade_tween.tween_property(boss.sprite, "modulate:a", 0.0, 1.5)
	await fade_tween.finished
	
	await boss.get_tree().create_timer(0.5).timeout
	
	# Trigger dungeon completion
	GameManager.complete_dungeon()


func physics_update(_delta: float) -> void:
	boss.velocity.x = 0


func handle_input(_event: InputEvent) -> void:
	pass
