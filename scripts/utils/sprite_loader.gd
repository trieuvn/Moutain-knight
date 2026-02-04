# Sprite Loader - Using real downloaded sprite sheets from OpenGameArt
extends Node
class_name SpriteLoader

# Downloaded sprite paths
const PLAYER_SPRITESHEET = "res://assets/sprites/player/knight_spritesheet.png"
const SKELETON_SPRITESHEET = "res://assets/sprites/enemies/skeleton_spritesheet.png"


static func setup_player_sprite_frames(sprite: AnimatedSprite2D) -> void:
	var sprite_frames = SpriteFrames.new()
	
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	# Try to load knight spritesheet
	var tex: Texture2D = null
	if ResourceLoader.exists(PLAYER_SPRITESHEET):
		tex = load(PLAYER_SPRITESHEET) as Texture2D
		print("✓ Loaded knight spritesheet")
	else:
		print("✗ Could not find knight spritesheet")
	
	if tex:
		# Knight spritesheet layout (16x16 frames, 64x64 canvas):
		# Row 1: idle (frames 0-4)
		# Row 2: run (frames 5-12) 
		# Row 3: jump (frames 13-15)
		# Row 4: fall (frames 16-17)
		# Row 5: attack (frames 18-23)
		# Row 6: hit (frame 24)
		# Row 7: dead (frames 25-31)
		# Row 8: block (frames 32-33)
		
		_add_spritesheet_animation(sprite_frames, "idle", tex, 0, 5, 6.0, true)
		_add_spritesheet_animation(sprite_frames, "run", tex, 5, 8, 12.0, true)
		_add_spritesheet_animation(sprite_frames, "jump", tex, 13, 3, 10.0, false)
		_add_spritesheet_animation(sprite_frames, "fall", tex, 16, 2, 8.0, true)
		_add_spritesheet_animation(sprite_frames, "attack_light_1", tex, 18, 6, 15.0, false)
		_add_spritesheet_animation(sprite_frames, "attack_light_2", tex, 18, 6, 15.0, false)
		_add_spritesheet_animation(sprite_frames, "attack_light_3", tex, 18, 6, 15.0, false)
		_add_spritesheet_animation(sprite_frames, "attack_heavy", tex, 18, 6, 12.0, false)
		_add_spritesheet_animation(sprite_frames, "hurt", tex, 24, 1, 10.0, false)
		_add_spritesheet_animation(sprite_frames, "death", tex, 25, 7, 8.0, false)
		_add_spritesheet_animation(sprite_frames, "dodge", tex, 32, 2, 15.0, false)
	else:
		# Fallback to placeholder
		_create_placeholder_animations(sprite_frames, Color(0.2, 0.4, 0.8), Vector2(48, 64))
	
	sprite.sprite_frames = sprite_frames
	sprite.play("idle")


static func setup_skeleton_sprite_frames(sprite: AnimatedSprite2D) -> void:
	var sprite_frames = SpriteFrames.new()
	
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	# Try to load skeleton spritesheet 
	var tex: Texture2D = null
	if ResourceLoader.exists(SKELETON_SPRITESHEET):
		tex = load(SKELETON_SPRITESHEET) as Texture2D
		print("✓ Loaded skeleton spritesheet")
	else:
		print("✗ Could not find skeleton spritesheet")
	
	if tex:
		# Skeleton spritesheet: 3 rows
		# Row 1: walk (4 frames)
		# Row 2: attack (7 frames)  
		# Row 3: dead (5 frames)
		
		var width = tex.get_width()
		var height = tex.get_height()
		var rows = 3
		var frame_height = height / rows
		
		# Walk animation - row 1
		_add_skeleton_row(sprite_frames, "idle", tex, 0, 4, frame_height, 6.0, true)
		_add_skeleton_row(sprite_frames, "walk", tex, 0, 4, frame_height, 8.0, true)
		
		# Attack animation - row 2
		_add_skeleton_row(sprite_frames, "attack", tex, 1, 7, frame_height, 12.0, false)
		
		# Dead animation - row 3
		_add_skeleton_row(sprite_frames, "hurt", tex, 2, 2, frame_height, 10.0, false)
		_add_skeleton_row(sprite_frames, "death", tex, 2, 5, frame_height, 8.0, false)
	else:
		# Fallback
		_create_placeholder_animations(sprite_frames, Color(0.7, 0.7, 0.7), Vector2(32, 48))
	
	sprite.sprite_frames = sprite_frames
	sprite.play("idle")


static func setup_boss_sprite_frames(sprite: AnimatedSprite2D) -> void:
	var sprite_frames = SpriteFrames.new()
	
	if sprite_frames.has_animation("default"):
		sprite_frames.remove_animation("default")
	
	# Boss uses larger placeholder for now
	_create_placeholder_animations(sprite_frames, Color(0.8, 0.2, 0.2), Vector2(80, 100))
	
	sprite.sprite_frames = sprite_frames
	sprite.play("idle")


# Add animation from horizontal spritesheet (all frames in one row)
static func _add_spritesheet_animation(
	frames: SpriteFrames,
	anim_name: String,
	texture: Texture2D,
	start_frame: int,
	frame_count: int,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, speed)
	frames.set_animation_loop(anim_name, loop)
	
	# Spritesheet is 64x64 per frame in a horizontal strip
	var frame_size = 64
	
	for i in range(frame_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2((start_frame + i) * frame_size, 0, frame_size, frame_size)
		frames.add_frame(anim_name, atlas)


# Add animation from skeleton spritesheet row
static func _add_skeleton_row(
	frames: SpriteFrames,
	anim_name: String,
	texture: Texture2D,
	row: int,
	frame_count: int,
	row_height: float,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(anim_name)
	frames.set_animation_speed(anim_name, speed)
	frames.set_animation_loop(anim_name, loop)
	
	var width = texture.get_width()
	var frame_width = width / frame_count
	
	for i in range(frame_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(i * frame_width, row * row_height, frame_width, row_height)
		frames.add_frame(anim_name, atlas)


static func _create_placeholder_animations(frames: SpriteFrames, color: Color, size: Vector2) -> void:
	var tex = _create_placeholder(color, size)
	var animations = ["idle", "run", "jump", "fall", "dodge",
					  "attack_light_1", "attack_light_2", "attack_light_3",
					  "attack_heavy", "attack_slash", "attack_overhead", "attack_shield",
					  "hurt", "death", "walk", "attack"]
	
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
