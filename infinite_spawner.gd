extends Node2D

@export var dog: Node2D
@export var mountain_chunk_scene: PackedScene # Drag mountain_chunk.tscn here!
@export var prop_scenes: Array[PackedScene]   # Drag tree.tscn and mushroom.tscn here!

# Exact pixel width and height of ONE mountain_chunk.tscn (adjust to match your chunk!)
@export var chunk_width: float = 256.0
@export var chunk_height: float = 192.0
@export var props_per_chunk: int = 3

var next_chunk_pos: Vector2 = Vector2.ZERO
var initialized: bool = false

func _process(_delta: float) -> void:
	if not dog or not mountain_chunk_scene:
		return

	# Start spawning right at the end of your starting mountain in main.tscn
	if not initialized:
		next_chunk_pos = Vector2(chunk_width, -chunk_height)
		initialized = true

	# Keep spawning chunks whenever the dog gets within 2 chunks of the end
	while dog.global_position.distance_to(next_chunk_pos) < chunk_width * 2.5:
		spawn_mountain_chunk()

func spawn_mountain_chunk() -> void:
	# 1. Spawn the solid mountain tiles
	var chunk = mountain_chunk_scene.instantiate()
	chunk.global_position = next_chunk_pos
	add_child(chunk)

	# 2. Spawn branches & mushrooms along the diagonal surface of this chunk
	if not prop_scenes.is_empty():
		for i in range(props_per_chunk):
			var progress: float = float(i + 1) / float(props_per_chunk + 1)
			var prop_scene: PackedScene = prop_scenes.pick_random()
			if prop_scene:
				var prop = prop_scene.instantiate()
				# Place the prop along the diagonal slope of the chunk
				var slope_x: float = next_chunk_pos.x + (chunk_width * progress)
				var slope_y: float = next_chunk_pos.y - (chunk_height * progress) - 12.0
				prop.global_position = Vector2(slope_x, slope_y)
				add_child(prop)

	# 3. Advance the spawn cursor to the exact top-right corner of this chunk
	next_chunk_pos += Vector2(chunk_width, -chunk_height)
