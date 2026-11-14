extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var age_label: Label = get_tree().current_scene.find_child("AgeLabel", true, false)
@onready var cutscene_player: VideoStreamPlayer = get_tree().current_scene.find_child("CutscenePlayer", true, false)
@onready var bg_music: AudioStreamPlayer = get_tree().current_scene.find_child("BGMusic", true, false)

@export var game_over_video: VideoStream # Drag gameover.ogv here in the Inspector!

# Base Adult stats (automatically adjusted by age)
var speed: float = 290.0
var jump_velocity: float = -315.0
var min_bounce: float = -310.0
var max_bounce: float = -600.0
var gravity_multiplier: float = 0.95

# Charge, Age & Cutscene state
var charge_ratio: float = 0.0
var charge_speed: float = 1.8
var age: int = 1 # 0-2: Puppy, 3-8: Adult, 9-11: Senior, 12: Game Over
var can_move: bool = false
var checkpoint_pos: Vector2

func _ready() -> void:
	checkpoint_pos = global_position
	update_age_stats()

func _physics_process(delta: float) -> void:
	if not can_move:
		return

	# 1. Apply Gravity
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# 2. Hold Spacebar to charge bounce
	if Input.is_action_pressed("ui_accept"):
		charge_ratio = move_toward(charge_ratio, 1.0, charge_speed * delta)
	else:
		charge_ratio = move_toward(charge_ratio, 0.0, charge_speed * 2.0 * delta)

	# 3. Auto-bounce ONLY on bouncy objects (tree/mushroom/snow); normal jump on ground
	if is_on_floor():
		var bounce_boost: float = get_bounce_object_multiplier()
		if bounce_boost > 0.0:
			var bounce_power = lerp(min_bounce, max_bounce, charge_ratio)
			velocity.y = bounce_power * bounce_boost
			charge_ratio = 0.0
		elif Input.is_action_just_pressed("ui_accept"):
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

	# 6. Respawn & age +1 year if the dog falls below its checkpoint
	if global_position.y > checkpoint_pos.y + 350.0:
		respawn_at_checkpoint()

func get_bounce_object_multiplier() -> float:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if not collider:
			continue
		if collider.is_in_group("mushroom"):
			return 1.6
		elif collider.is_in_group("tree"):
			return 1.1
		elif collider.is_in_group("snow"):
			return 0.7
	return 0.0

func update_animation(direction: float) -> void:
	if not sprite or not sprite.sprite_frames:
		return
	if not is_on_floor():
		if sprite.sprite_frames.has_animation("jump"):
			sprite.play("jump")
		elif sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	elif abs(direction) > 0.0:
		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	else:
		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")
		else:
			sprite.stop()
			sprite.frame = 0

func set_age(new_age: int) -> void:
	age = max(0, new_age)
	update_age_stats()

func update_age_stats() -> void:
	var stage_name := "Puppy"
	if age <= 2: # Puppy (Ages 0-2)
		stage_name = "Puppy"
		speed = 330.0
		jump_velocity = -340.0
		min_bounce = -340.0
		max_bounce = -700.0
		gravity_multiplier = 0.85
		sprite.modulate = Color(1, 1, 1)
	elif age <= 8: # Adult (Ages 3-8, including Age 5)
		stage_name = "Adult"
		speed = 290.0
		jump_velocity = -315.0
		min_bounce = -310.0
		max_bounce = -600.0
		gravity_multiplier = 0.95
		sprite.modulate = Color(1, 1, 1)
	else: # Senior (Ages 9-11)
		stage_name = "Senior"
		speed = 230.0
		jump_velocity = -280.0
		min_bounce = -280.0
		max_bounce = -500.0
		gravity_multiplier = 1.05
		sprite.modulate = Color(0.75, 0.78, 0.85)

	if age_label:
		age_label.text = "Age: %d yrs (%s)" % [age, stage_name]

func take_damage_and_respawn() -> void:
	respawn_at_checkpoint()

func respawn_at_checkpoint() -> void:
	velocity = Vector2.ZERO
	charge_ratio = 0.0
	set_age(age + 1)
	if age >= 12:
		trigger_game_over()
		return
	global_position = checkpoint_pos

func trigger_game_over() -> void:
	can_move = false
	velocity = Vector2.ZERO
	if bg_music:
		bg_music.stop()
	if cutscene_player and game_over_video:
		cutscene_player.visible = true
		cutscene_player.stream = game_over_video
		cutscene_player.play()
	else:
		var game_over_menu = get_tree().current_scene.find_child("GameOverMenu", true, false)
		if game_over_menu:
			game_over_menu.visible = true

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
