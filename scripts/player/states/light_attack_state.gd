# Player Light Attack State
extends State

@onready var player: CharacterBody2D = owner
var attack_duration: float = 0.0
var hitbox_enabled: bool = false
const HITBOX_START_FRAME: float = 0.1
const HITBOX_END_FRAME: float = 0.2


func enter(_data: Dictionary = {}) -> void:
	super.enter(_data)
	player.light_attack()
	
	# Play attack animation based on combo
	var anim_name = "attack_light_" + str(player.combo_count)
	if player.sprite.sprite_frames.has_animation(anim_name):
		player.sprite.play(anim_name)
	else:
		player.sprite.play("attack_light_1")
	
	attack_duration = GameConstants.LIGHT_ATTACK_DURATION
	hitbox_enabled = false
	
	# Reduce movement during attack
	player.velocity.x *= 0.3


func exit() -> void:
	super.exit()
	player.end_attack()


func physics_update(delta: float) -> void:
	attack_duration -= delta
	
	# Enable hitbox during active frames
	var elapsed = GameConstants.LIGHT_ATTACK_DURATION - attack_duration
	if elapsed >= HITBOX_START_FRAME and elapsed < HITBOX_END_FRAME and not hitbox_enabled:
		player.enable_hitbox()
		hitbox_enabled = true
	elif elapsed >= HITBOX_END_FRAME and hitbox_enabled:
		player.disable_hitbox()
		hitbox_enabled = false
	
	# Slow deceleration during attack
	player.velocity.x = move_toward(player.velocity.x, 0, 500 * delta)
	
	# End attack
	if attack_duration <= 0:
		if player.is_on_floor():
			state_machine.change_state(&"Idle")
		else:
			state_machine.change_state(&"Fall")


func handle_input(event: InputEvent) -> void:
	# Buffer next attack
	if event.is_action_pressed("light_attack"):
		player.attack_buffered = true
	elif event.is_action_pressed("dodge") and attack_duration < GameConstants.LIGHT_ATTACK_DURATION * 0.5:
		# Can cancel into dodge in latter half of attack
		state_machine.change_state(&"Dodge")
