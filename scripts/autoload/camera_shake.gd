# Camera Shake Effect Manager
extends Node

var camera: Camera2D = null
var shake_amount: float = 0.0
var shake_duration: float = 0.0
var original_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Auto-find Camera2D in scene
	call_deferred("_find_camera")


func _find_camera() -> void:
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		camera = cameras[0]
		original_offset = camera.offset


func _process(delta: float) -> void:
	if shake_duration > 0 and camera:
		shake_duration -= delta
		
		if shake_duration > 0:
			# Apply random offset
			var offset_x = randf_range(-shake_amount, shake_amount)
			var offset_y = randf_range(-shake_amount, shake_amount)
			camera.offset = Vector2(offset_x, offset_y)
		else:
			# Reset to original
			camera.offset = original_offset
			shake_amount = 0.0


## Trigger camera shake
func shake(strength: float = 5.0, duration: float = 0.2) -> void:
	if not camera:
		return
	
	shake_amount = max(shake_amount, strength)
	shake_duration = max(shake_duration, duration)
