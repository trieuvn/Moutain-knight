# Death Explosion Effect
extends CPUParticles2D

func _ready() -> void:
	one_shot = true
	emitting = true
	
	# Particle settings
	amount = 20
	lifetime = 1.0
	explosiveness = 1.0
	
	# Visual
	color = Color(0.3, 0.1, 0.2, 1)
	color_ramp = Gradient.new()
	color_ramp.add_point(0.0, Color(0.6, 0.2, 0.3, 1))
	color_ramp.add_point(0.5, Color(0.4, 0.1, 0.2, 0.8))
	color_ramp.add_point(1.0, Color(0.2, 0.05, 0.1, 0))
	
	# Shape
	emission_shape = EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 8.0
	
	# Movement
	direction = Vector2(0, -1)
	spread = 180
	initial_velocity_min = 80.0
	initial_velocity_max = 180.0
	gravity = Vector2(0, 150)
	
	# Size
	scale_amount_min = 4.0
	scale_amount_max = 8.0
	
	# Auto-cleanup
	await get_tree().create_timer(lifetime + 0.2).timeout
	queue_free()
