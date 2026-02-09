# Sprite Loader - Using PixelLab-generated sprites for side-scroller
extends Node
class_name SpriteLoader

# PixelLab sprite paths
const PLAYER_PATH = "res://assets/sprites/player/penitent_knight/"
const SKELETON_PATH = "res://assets/sprites/enemies/skeleton_warrior/"
const BOSS_PATH = "res://assets/sprites/bosses/corrupted_bishop/"


static func setup_player_sprite_frames(sprite: AnimatedSprite2D) -> void:
	var sprite_frames = SpriteFrames.new()
	
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	# Load PixelLab generated sprites
	var base_path = PLAYER_PATH
	var rotations_path = base_path + "rotations/"
	var animations_path = base_path + "animations/"
	
	# Check if PixelLab sprites exist
	if ResourceLoader.exists(rotations_path + "east.png"):
		print("✓ Loading PixelLab Penitent Knight sprites")
		
		# Load directional static sprites (for when no animation is playing)
		var east_tex = load(rotations_path + "east.png") as Texture2D
		var west_tex = load(rotations_path + "west.png") as Texture2D
		
		# For 2D side-scroller, we mainly use east/west
		# Create idle animation - use static sprite or animation frames if available
		if ResourceLoader.exists(animations_path + "breathing-idle/south/frame_000.png"):
			# Use breathing-idle animation
			_add_animation_from_folder(sprite_frames, "idle", animations_path + "breathing-idle/south/", 8.0, true)
		else:
			# Fallback to static east sprite
			_add_single_frame(sprite_frames, "idle", east_tex, 8.0, true)
		
		# Other animations - use static sprites for now
		# Run: use east sprite
		_add_single_frame(sprite_frames, "run", east_tex, 12.0, true)
		
		# Jump: use east sprite
		_add_single_frame(sprite_frames, "jump", east_tex, 10.0, false)
		
		# Fall: use east sprite  
		_add_single_frame(sprite_frames, "fall", east_tex, 8.0, true)
		
		# Attack animations
		_add_single_frame(sprite_frames, "attack_light_1", east_tex, 15.0, false)
		_add_single_frame(sprite_frames, "attack_light_2", east_tex, 15.0, false)
		_add_single_frame(sprite_frames, "attack_light_3", east_tex, 15.0, false)
		_add_single_frame(sprite_frames, "attack_heavy", east_tex, 12.0, false)
		
		# Hurt/Death
		_add_single_frame(sprite_frames, "hurt", east_tex, 10.0, false)
		_add_single_frame(sprite_frames, "death", east_tex, 8.0, false)
		
		# Dodge
		_add_single_frame(sprite_frames, "dodge", east_tex, 15.0, false)
		
		print("✓ PixelLab player sprites loaded")
	else:
		print("✗ PixelLab sprites not found, using placeholder")
		_create_placeholder_animations(sprite_frames, Color(0.2, 0.4, 0.8), Vector2(64, 64))
	
	sprite.sprite_frames = sprite_frames
	sprite.play("idle")


static func setup_skeleton_sprite_frames(sprite: AnimatedSprite2D) -> void:
	var sprite_frames = SpriteFrames.new()
	
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	var base_path = SKELETON_PATH
	var rotations_path = base_path + "rotations/"
	
	if ResourceLoader.exists(rotations_path + "east.png"):
		print("✓ Loading PixelLab Skeleton Warrior sprites")
		
		var east_tex = load(rotations_path + "east.png") as Texture2D
		
		# Create all animations using static sprite
		_add_single_frame(sprite_frames, "idle", east_tex, 6.0, true)
		_add_single_frame(sprite_frames, "walk", east_tex, 8.0, true)
		_add_single_frame(sprite_frames, "attack", east_tex, 12.0, false)
		_add_single_frame(sprite_frames, "hurt", east_tex, 10.0, false)
		_add_single_frame(sprite_frames, "death", east_tex, 8.0, false)
		
		print("✓ PixelLab skeleton sprites loaded")
	else:
		print("✗ PixelLab skeleton sprites not found, using placeholder")
		_create_placeholder_animations(sprite_frames, Color(0.7, 0.7, 0.7), Vector2(48, 48))
	
	sprite.sprite_frames = sprite_frames
	sprite.play("idle")


static func setup_boss_sprite_frames(sprite: AnimatedSprite2D) -> void:
	var sprite_frames = SpriteFrames.new()
	
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	var base_path = BOSS_PATH
	var rotations_path = base_path + "rotations/"
	
	if ResourceLoader.exists(rotations_path + "east.png"):
		print("✓ Loading PixelLab Corrupted Bishop Boss sprites")
		
		var east_tex = load(rotations_path + "east.png") as Texture2D
		
		# Boss animations
		_add_single_frame(sprite_frames, "idle", east_tex, 4.0, true)
		_add_single_frame(sprite_frames, "walk", east_tex, 6.0, true)
		
		# Attack patterns for boss
		_add_single_frame(sprite_frames, "attack_slash", east_tex, 12.0, false)
		_add_single_frame(sprite_frames, "attack_overhead", east_tex, 10.0, false)
		_add_single_frame(sprite_frames, "attack_shield", east_tex, 8.0, false)
		_add_single_frame(sprite_frames, "attack", east_tex, 12.0, false)
		
		# Utility
		_add_single_frame(sprite_frames, "hurt", east_tex, 10.0, false)
		_add_single_frame(sprite_frames, "death", east_tex, 6.0, false)
		_add_single_frame(sprite_frames, "stun", east_tex, 8.0, true)
		
		print("✓ PixelLab boss sprites loaded")
	else:
		print("✗ PixelLab boss sprites not found, using placeholder")
		_create_placeholder_animations(sprite_frames, Color(0.8, 0.2, 0.2), Vector2(128, 128))
	
	sprite.sprite_frames = sprite_frames
	sprite.play("idle")


# Add animation from folder of frame images
static func _add_animation_from_folder(
	frames: SpriteFrames,
	anim_name: String,
	folder_path: String,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, speed)
	frames.set_animation_loop(anim_name, loop)
	
	# Load frames in order
	var frame_idx = 0
	while true:
		var frame_path = folder_path + "frame_%03d.png" % frame_idx
		if ResourceLoader.exists(frame_path):
			var tex = load(frame_path) as Texture2D
			frames.add_frame(anim_name, tex)
			frame_idx += 1
		else:
			break
	
	if frame_idx == 0:
		# No frames found, add placeholder
		var placeholder = _create_placeholder(Color.MAGENTA, Vector2(64, 64))
		frames.add_frame(anim_name, placeholder)


# Add single frame as animation
static func _add_single_frame(
	frames: SpriteFrames,
	anim_name: String,
	texture: Texture2D,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, speed)
	frames.set_animation_loop(anim_name, loop)
	frames.add_frame(anim_name, texture)


static func _create_placeholder_animations(frames: SpriteFrames, color: Color, size: Vector2) -> void:
	var tex = _create_placeholder(color, size)
	var animations = ["idle", "run", "jump", "fall", "dodge",
					  "attack_light_1", "attack_light_2", "attack_light_3",
					  "attack_heavy", "attack_slash", "attack_overhead", "attack_shield",
					  "hurt", "death", "walk", "attack", "stun"]
	
	for anim_name in animations:
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, 8.0)
		frames.set_animation_loop(anim_name, anim_name in ["idle", "run", "walk", "fall"])
		frames.add_frame(anim_name, tex)


static func _create_placeholder(color: Color, size: Vector2) -> ImageTexture:
	var img = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	
	var border = color.darkened(0.3)
	for x in range(int(size.x)):
		img.set_pixel(x, 0, border)
		img.set_pixel(x, int(size.y) - 1, border)
	for y in range(int(size.y)):
		img.set_pixel(0, y, border)
		img.set_pixel(int(size.x) - 1, y, border)
	
	return ImageTexture.create_from_image(img)
