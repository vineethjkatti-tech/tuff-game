extends CharacterBody2D


@onready var age_label: Label = get_tree().current_scene.find_child("AgeLabel", true, false)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Change to Sprite2D if not animated
@onready var game_over_menu: Control = get_tree().current_scene.find_child("GameOverMenu", true, false)
@onready var bg_music: AudioStreamPlayer = get_tree().current_scene.find_child("BGMusic", true, false)
@export var game_over_video: VideoStream # Drag gameover.ogv here in the Inspector!
@onready var cutscene_player: VideoStreamPlayer = get_tree().current_scene.find_child("CutscenePlayer", true, false)


var can_move: bool = false # Starts false until the intro animation finishes!
var speed: float = 250.0
var checkpoint_pos: Vector2
var jump_velocity: float = -420.0
var min_bounce: float = -450.0
var max_bounce: float = -820.0
var gravity_multiplier: float = 1.0

var charge_ratio: float = 0.0
var charge_speed: float = 1.8
var age: int = 1 # 0-2: Puppy, 3-8: Adult, 9+: Senior

func _ready() -> void:
	checkpoint_pos = global_position
	update_age_stats()

func _physics_process(delta: float) -> void:
	
	if not can_move:
		return
	
	# 1. Gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# 2. Hold Spacebar in mid-air (or on ground) to charge a bounce
	if Input.is_action_pressed("ui_accept"):
		charge_ratio = move_toward(charge_ratio, 1.0, charge_speed * delta)
	else:
		charge_ratio = move_toward(charge_ratio, 0.0, charge_speed * 2.0 * delta)

	# 3. Check what we landed on when touching a floor/surface
	if is_on_floor():
		var bounce_boost: float = get_bounce_object_multiplier()
		
		if bounce_boost > 0.0:
			# Landed on a bouncy object (tree, mushroom, snow, etc.) -> BOUNCE!
			var bounce_power = lerp(min_bounce, max_bounce, charge_ratio)
			velocity.y = bounce_power * bounce_boost
			charge_ratio = 0.0
		elif Input.is_action_just_pressed("ui_accept"):
			# Standing on regular Ground -> Only jump when Spacebar is pressed!
			velocity.y = jump_velocity
			charge_ratio = 0.0

	# 4. Left / Right movement & air steering
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * 8.0 * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 5.0 * delta)

	# 5. Squash & stretch visual feedback while charging
	sprite.scale.y = lerp(1.0, 0.75, charge_ratio)
	sprite.scale.x = lerp(1.0, 1.25, charge_ratio)

	move_and_slide()
	update_animation(direction)
	
	# Respawn if the dog falls 350 pixels below its checkpoint
	if global_position.y > checkpoint_pos.y + 350.0:
		respawn_at_checkpoint()

# Returns > 0.0 ONLY if the collided object is in a bouncy group
func get_bounce_object_multiplier() -> float:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if not collider:
			continue
		if collider.is_in_group("mushroom"):
			return 1.35 # High bounce!
		elif collider.is_in_group("tree"):
			return 1.1 # Standard bounce off tree branches!
		elif collider.is_in_group("snow"):
			return 0.7 # Soft bounce on snow
	return 0.0 # Regular ground -> Do NOT auto-bounce

func set_age(new_age: int) -> void:
	age = max(0, new_age)
	update_age_stats()

func update_age_stats() -> void:
	var stage_name := "Puppy"
	if age <= 2: # Puppy
		stage_name = "Puppy"
		speed = 330.0
		jump_velocity = -300.0
		min_bounce = -200.0
		max_bounce = -700.0
		gravity_multiplier = 0.85
		sprite.modulate = Color(1, 1, 1)
	elif age <= 8: # Adult
		stage_name = "Adult"
		speed = 280.0
		jump_velocity = -270.0
		min_bounce = -150.0
		max_bounce = -500.0
		gravity_multiplier = 1.0
		sprite.modulate = Color(1, 1, 1)
	else: # Senior
		stage_name = "Senior"
		speed = 210.0
		jump_velocity = -140.0
		min_bounce = -320.0
		max_bounce = -640.0
		gravity_multiplier = 1.15
		sprite.modulate = Color(0.75, 0.78, 0.85) # Grey muzzle tint!

	if age_label:
		age_label.text = "Age: %d yrs (%s)" % [age, stage_name]

func take_damage_and_respawn() -> void:
	respawn_at_checkpoint()

func respawn_at_checkpoint() -> void:
	velocity = Vector2.ZERO
	charge_ratio = 0.0
	set_age(age + 1) # Lose 1 year of life on death!
	if age >= 12:
		trigger_game_over()
		return
	global_position = checkpoint_pos
	print("Respawned! Dog age is now: ", age)

func trigger_game_over() -> void:
	if "can_move" in self:
		can_move = false
	velocity = Vector2.ZERO
	if bg_music:
		bg_music.stop()
	if cutscene_player and game_over_video:
		cutscene_player.visible = true
		cutscene_player.stream = game_over_video
		cutscene_player.play()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func update_animation(direction: float) -> void:
	if not is_on_floor():
		if sprite.sprite_frames.has_animation("jump"):
			sprite.play("jump")
		else:
			sprite.play("walk")
	elif abs(direction) > 0.0:
		sprite.play("walk")
	else:
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			sprite.stop()
			sprite.frame = 0
