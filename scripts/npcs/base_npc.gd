# Base NPC script with AnimatedSprite2D support
extends Area2D
class_name BaseNPC

@export var npc_name: String = "NPC"
@export var npc_type: String = "generic"  # "merchant", "blacksmith", "elder"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
@onready var interact_label: Label = $InteractLabel

var player_in_range: bool = false


func _ready() -> void:
	_load_sprites()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _load_sprites() -> void:
	if not sprite:
		return
	
	match npc_type:
		"merchant":
			SpriteLoader.setup_nun_shopkeeper_sprite_frames(sprite)
		"blacksmith":
			# Use placeholder for now (no blacksmith sprite yet)
			_create_placeholder_sprite(Color(0.5, 0.3, 0.2))
		"elder":
			# Use placeholder for now
			_create_placeholder_sprite(Color(0.4, 0.3, 0.5))
		_:
			_create_placeholder_sprite(Color(0.5, 0.5, 0.5))


func _create_placeholder_sprite(color: Color) -> void:
	var frames = SpriteFrames.new()
	frames.add_animation("idle")
	
	var img = Image.create(32, 64, false, Image.FORMAT_RGBA8)
	img.fill(color)
	var tex = ImageTexture.create_from_image(img)
	frames.add_frame("idle", tex)
	
	sprite.sprite_frames = frames
	sprite.play("idle")


func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		_on_interact()


func _on_interact() -> void:
	print("Interacting with: ", npc_name)
	# Override in child classes for specific behavior


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if interact_label:
			interact_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if interact_label:
			interact_label.visible = false
