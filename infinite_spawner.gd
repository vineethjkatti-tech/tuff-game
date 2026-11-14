extends Node2D

@export var dog: Node2D
@export var mountain_chunk_scene: PackedScene # Drag mountain_chunk.tscn here!
@export var enemy_scene: PackedScene          # Drag enemy.tscn here!
@export var ending_video: VideoStream         # Drag ending.ogv here!
@onready var bg_music: AudioStreamPlayer = get_tree().current_scene.find_child("BGMusic", true, false)
# Exact pixel width and height of your tile staircase (tiles * 16)
@export var chunk_width: float = 272.0
@export var chunk_height: float = 176.0
@export var total_chunks_to_summit: int = 15  # Ending triggers at chunk 15!
@onready var end_menu: Control = get_tree().current_scene.find_child("EndMenu", true, false)
@onready var whiteout_rect: ColorRect = $"../CutsceneLayer/WhiteoutRect"
@onready var cutscene_player: VideoStreamPlayer = get_tree().current_scene.find_child("CutscenePlayer", true, false)
@onready var end_text_label: Label = get_tree().current_scene.find_child("EndTextLabel", true, false)
@onready var game_over_menu: Control = get_tree().current_scene.find_child("GameOverMenu", true, false)

var next_chunk_pos: Vector2 = Vector2.ZERO
var initialized: bool = false
var chunks_spawned: int = 0
var start_y: float = 0.0
var summit_y: float = 0.0
var ending_triggered: bool = false
var can_restart: bool = false

func _ready() -> void:
	if dog:
		start_y = dog.global_position.y
		summit_y = start_y - (total_chunks_to_summit * chunk_height)
	play_intro_cutscene()

func _process(_delta: float) -> void:
	if not dog or not mountain_chunk_scene or ending_triggered:
		return

	# Align the first spawned chunk directly to the end of the starting TileMapLayer in main.tscn
	if not initialized:
		var start_tilemap = get_parent().get_node_or_null("TileMapLayer")
		if start_tilemap:
			next_chunk_pos = start_tilemap.global_position + Vector2(chunk_width, -chunk_height)
		else:
			next_chunk_pos = Vector2(chunk_width, -chunk_height)
		initialized = true

	# Keep spawning chunks up to the summit whenever the dog gets within 2.5 chunks of the frontier
	while chunks_spawned < total_chunks_to_summit and dog.global_position.distance_to(next_chunk_pos) < chunk_width * 2.5:
		spawn_mountain_chunk()

	# Slowly brighten the white light at first, then surge fast near the summit!
	update_summit_light()

func spawn_mountain_chunk() -> void:
	chunks_spawned += 1
	var chunk = mountain_chunk_scene.instantiate()
	chunk.global_position = next_chunk_pos
	add_child(chunk)

	# Progress from 0.0 (start) to 1.0 (summit)
	var progress: float = clamp(float(chunks_spawned) / float(total_chunks_to_summit), 0.0, 1.0)

	# Spawn enemies rarely early on (15%) and frequently near the end (85%)
	if enemy_scene and chunks_spawned > 1:
		var spawn_chance: float = lerp(0.15, 0.85, progress)
		if randf() < spawn_chance:
			var enemy = enemy_scene.instantiate()
			enemy.global_position = next_chunk_pos + Vector2(chunk_width * 0.55, -chunk_height * 0.55 - 12.0)
			if "vertical_patrol" in enemy and randf() < 0.4:
				enemy.vertical_patrol = true
			add_child(enemy)

	# Advance to the exact top-right corner of this chunk
	next_chunk_pos += Vector2(chunk_width, -chunk_height)

func update_summit_light() -> void:
	var climb_ratio: float = clamp((start_y - dog.global_position.y) / (start_y - summit_y), 0.0, 1.0)
	if whiteout_rect:
		whiteout_rect.color.a = pow(climb_ratio, 4.0)

	if climb_ratio >= 0.98 and not ending_triggered:
		trigger_ending()

func play_intro_cutscene() -> void:
	if cutscene_player and cutscene_player.stream:
		cutscene_player.visible = true
		if bg_music:
			bg_music.stream_paused = true
		if dog and "can_move" in dog:
			dog.can_move = false
	else:
		if dog and "can_move" in dog:
			dog.can_move = true

func _on_cutscene_player_finished() -> void:
	# 1. Game Over video finished -> show GameOverMenu!
	if dog and "age" in dog and dog.age >= 12:
		if game_over_menu:
			game_over_menu.visible = true
		return

	# 2. Intro video finished -> hide video and start gameplay
	if not ending_triggered:
		if cutscene_player:
			cutscene_player.visible = false
		if dog and "can_move" in dog:
			dog.can_move = true
		if bg_music:
			bg_music.stream_paused = false
			if not bg_music.playing:
				bg_music.play()
		# 3. Ending video finished -> show EndMenu
	else:
		if end_menu:
			end_menu.visible = true
		can_restart = true
		
func trigger_ending() -> void:
	ending_triggered = true
	if bg_music:
		bg_music.stop()
	if whiteout_rect:
		whiteout_rect.color.a = 1.0
	if dog and "can_move" in dog:
		dog.can_move = false
		dog.velocity = Vector2.ZERO

	if cutscene_player and ending_video:
		cutscene_player.visible = true
		cutscene_player.stream = ending_video
		cutscene_player.play()
	else:
		if end_menu:
			end_menu.visible = true
		can_restart = true	

func _on_play_again_button_pressed() -> void:
	get_tree().reload_current_scene()
