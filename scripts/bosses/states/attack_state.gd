# Boss Attack State - Executes attacks
extends State

@onready var boss: BaseBoss = owner
var current_attack: Dictionary
var attack_phase: int = 0  # 0=telegraph, 1=execute, 2=recovery
var phase_timer: float = 0.0


func enter(data: Dictionary = {}) -> void:
	super.enter(data)
	current_attack = data.get("attack_data", {})
	attack_phase = 0
	
	if current_attack.is_empty():
		state_machine.change_state(&"Idle")
		return
	
	boss.is_attacking = true
	boss.update_facing()
	boss.velocity.x = 0
	
	# Start telegraph phase
	var telegraph_time = current_attack.get("telegraph", 0.5)
	phase_timer = telegraph_time
	
	boss.sprite.play("telegraph")
	boss.telegraph_started.emit(current_attack.get("name", "attack"), telegraph_time)


func exit() -> void:
	super.exit()
	boss.is_attacking = false
	boss.attack_ended.emit()


func physics_update(delta: float) -> void:
	phase_timer -= delta
	
	match attack_phase:
		0:  # Telegraph
			if phase_timer <= 0:
				_start_attack_execution()
		1:  # Execute
			_update_attack_execution(delta)
		2:  # Recovery
			if phase_timer <= 0:
				state_machine.change_state(&"Idle")


func _start_attack_execution() -> void:
	attack_phase = 1
	var attack_name = current_attack.get("name", "attack")
	var anim_name = current_attack.get("animation", "attack")
	
	boss.sprite.play(anim_name)
	boss.attack_started.emit(attack_name)
	
	# Set attack duration
	phase_timer = current_attack.get("duration", 0.6)
	
	# Handle movement during attack
	var movement = current_attack.get("movement", {})
	if movement.has("lunge"):
		boss.velocity.x = boss.facing_direction * movement.lunge


func _update_attack_execution(delta: float) -> void:
	# Handle hitbox timing
	var hitbox_timing = current_attack.get("hitbox", {})
	var elapsed = current_attack.get("duration", 0.6) - phase_timer
	
	if hitbox_timing.has("start") and hitbox_timing.has("end"):
		if elapsed >= hitbox_timing.start and elapsed < hitbox_timing.end:
			_enable_attack_hitboxes()
		elif elapsed >= hitbox_timing.end:
			_disable_attack_hitboxes()
	
	# Movement deceleration
	boss.velocity.x = move_toward(boss.velocity.x, 0, 400 * delta)
	
	# Check if attack finished
	if phase_timer <= 0:
		_disable_attack_hitboxes()
		attack_phase = 2
		phase_timer = current_attack.get("recovery", 0.3)
		boss.sprite.play("idle")


func _enable_attack_hitboxes() -> void:
	var hitbox_names = current_attack.get("hitboxes", ["Hitbox"])
	for hitbox_name in hitbox_names:
		var hitbox = boss.get_node_or_null(hitbox_name)
		if hitbox and hitbox is Hitbox:
			hitbox.damage = current_attack.get("damage", boss.base_attack_damage)
			hitbox.enable()


func _disable_attack_hitboxes() -> void:
	for child in boss.get_children():
		if child is Hitbox:
			child.disable()


func handle_input(_event: InputEvent) -> void:
	pass
