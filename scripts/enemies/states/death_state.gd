# Enemy Death State
extends State

@onready var enemy: BaseEnemy = owner


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	enemy.sprite.play("death")
	enemy.velocity = Vector2.ZERO
	
	# Wait for animation then remove
	await enemy.sprite.animation_finished
	await enemy.get_tree().create_timer(0.5).timeout
	
	# Fade out and remove
	var tween = enemy.create_tween()
	tween.tween_property(enemy.sprite, "modulate:a", 0.0, 0.5)
	await tween.finished
	
	enemy.queue_free()


func physics_update(_delta: float) -> void:
	enemy.velocity.x = 0


func handle_input(_event: InputEvent) -> void:
	pass
