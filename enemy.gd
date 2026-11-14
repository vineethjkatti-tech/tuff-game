extends Area2D

@export var move_distance: float = 48.0
@export var move_speed: float = 55.0
@export var vertical_patrol: bool = false # Check this ON in Inspector to make a swooping bird!

var start_pos: Vector2
var time_passed: float = 0.0

func _ready() -> void:
	start_pos = global_position
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time_passed += delta * (move_speed / 30.0)
	var offset := sin(time_passed) * move_distance
	if vertical_patrol:
		global_position.y = start_pos.y + offset
	else:
		global_position.x = start_pos.x + offset
		if has_node("Sprite2D"):
			$Sprite2D.flip_h = cos(time_passed) < 0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Dog" or body.is_in_group("dog"):
		# If the dog is falling onto the enemy from above -> stomp & bounce!
		if body.velocity.y > 0.0 and body.global_position.y < global_position.y - 4.0:
			body.velocity.y = -320.0
			queue_free()
		# Otherwise, the enemy hits the dog -> lose 1 year & respawn!
		elif body.has_method("take_damage_and_respawn"):
			body.take_damage_and_respawn()
