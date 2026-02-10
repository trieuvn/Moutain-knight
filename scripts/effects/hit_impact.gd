# Hit Impact Effect - Blood splatter particle
extends CPUParticles2D

func _ready() -> void:
	one_shot = true
	emitting = true
	
	# Particle settings
	amount = 12
	lifetime = 0.6
	explosiveness = 0.8
	
	# Visual
	color = Color(0.8, 0.1, 0.15, 1)
	color_ramp = Gradient.new()
	color_ramp.add_point(0.0, Color(0.9, 0.2, 0.2, 1))
	color_ramp.add_point(1.0, Color(0.5, 0.1, 0.1, 0))
	
	# Shape
	emission_shape = EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 5.0
	
	# Movement
	direction = Vector2(0, -1)
	spread = 180
	initial_velocity_min = 50.0
	initial_velocity_max = 120.0
	gravity = Vector2(0, 200)
	
	# Size
	scale_amount_min = 3.0
	scale_amount_max = 6.0
	
	# Auto-cleanup
	await get_tree().create_timer(lifetime + 0.2).timeout
	queue_free()
