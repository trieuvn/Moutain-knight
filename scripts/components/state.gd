# State - Base class for all states in the state machine
class_name State
extends Node

signal state_entered
signal state_exited

var state_machine: StateMachine

# Override in child states
func enter(_data: Dictionary = {}) -> void:
	state_entered.emit()


func exit() -> void:
	state_exited.emit()


func update(_delta: float) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass
