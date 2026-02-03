# State Machine - Reusable FSM for player, enemies, and bosses
class_name StateMachine
extends Node

signal state_changed(old_state: StringName, new_state: StringName)

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	# Wait for owner to be ready
	await owner.ready
	
	# Collect all State children
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.state_machine = self
			child.state_entered.connect(_on_state_entered.bind(child))
			child.state_exited.connect(_on_state_exited.bind(child))
	
	# Initialize with initial state
	if initial_state:
		current_state = initial_state
		current_state.enter()


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func change_state(new_state_name: StringName, data: Dictionary = {}) -> void:
	if not states.has(new_state_name):
		push_error("State '%s' not found in state machine" % new_state_name)
		return
	
	var old_state_name := current_state.name if current_state else &""
	
	if current_state:
		current_state.exit()
	
	current_state = states[new_state_name]
	current_state.enter(data)
	
	state_changed.emit(old_state_name, new_state_name)


func _on_state_entered(state: State) -> void:
	pass  # Can be used for debugging


func _on_state_exited(state: State) -> void:
	pass  # Can be used for debugging
