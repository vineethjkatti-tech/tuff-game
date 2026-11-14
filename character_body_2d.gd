extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Base Adult stats (automatically adjusted by age)
var speed: float = 280.0
var min_bounce: float = -420.0
var max_bounce: float = -780.0
var gravity_multiplier: float = 1.0

# Charge & Age state
var charge_ratio: float = 0.0
var charge_speed: float = 1.8
var age: int = 1 # Start as Puppy (0-2), Adult (3-8), Senior (9+)

func _ready() -> void:
	update_age_stats()

func _physics_process(delta: float) -> void:
	# 1. Apply Gravity (floatier for puppies, heavier for seniors)
	if not is_on_floor():
		velocity += get_gravity() * gravity_multiplier * delta

	# 2. Hold Space / Jump to charge the next bounce
	if Input.is_action_pressed("ui_accept"):
		charge_ratio = move_toward(charge_ratio, 1.0, charge_speed * delta)
	else:
		charge_ratio = move_toward(charge_ratio, 0.0, charge_speed * 2.0 * delta)

	# 3. Auto-Bounce the instant the dog touches the ground or a platform
	if is_on_floor():
		# Check if we landed on a special bouncy object (like mushroom.png!)
		var bounce_boost: float = get_surface_multiplier()
		var jump_power = lerp(min_bounce, max_bounce, charge_ratio)
		
		velocity.y = jump_power * bounce_boost
		charge_ratio = 0.0 # Reset charge after launching

	# 4. Left / Right air steering
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, speed * 8.0 * delta)
		sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 5.0 * delta)

	# 5. Squash & Stretch visual feedback while charging
	sprite.scale.y = lerp(1.0, 0.75, charge_ratio)
	sprite.scale.x = lerp(1.0, 1.25, charge_ratio)

	move_and_slide()

# Checks if the object we bounced off is in a special group (e.g., "mushroom")
func get_surface_multiplier() -> float:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.is_in_group("mushroom"):
			return 1.6 # Launches 60% higher!
		elif collider and collider.is_in_group("snow"):
			return 0.7 # Snow absorbs part of the bounce
	return 1.0

# Call this when the dog dies (+1 year) or eats a bone (-1 year)
func set_age(new_age: int) -> void:
	age = max(0, new_age)
	update_age_stats()

func update_age_stats() -> void:
	if age <= 2: # Puppy: fast, floaty, huge bounces
		speed = 330.0
		min_bounce = -480.0
		max_bounce = -860.0
		gravity_multiplier = 0.85
	elif age <= 8: # Adult: balanced
		speed = 280.0
		min_bounce = -420.0
		max_bounce = -780.0
		gravity_multiplier = 1.0
	else: # Senior: slower, shorter hops, heavier
		speed = 210.0
		min_bounce = -340.0
		max_bounce = -600.0
		gravity_multiplier = 1.15
