extends Camera2D

@export var target: Node2D
@export var follow_speed: float = 6.0
@export var look_ahead_offset: Vector2 = Vector2(60, -30)

func _ready() -> void:
	make_current() # Forces Godot to use this camera!
	if target:
		global_position = target.global_position + look_ahead_offset

func _process(delta: float) -> void:
	if not target:
		return
	var desired_pos = target.global_position + look_ahead_offset
	global_position = global_position.lerp(desired_pos, follow_speed * delta)
