extends Area2D

@export_multiline var poetic_lines: Array[String] = [
	"Every fall steals a summer from your bones, little traveler... climb before winter claims your stride.",
	"Death here does not end the road; it only turns your coat to silver and makes the summit steeper.",
	"He still calls your name into the wind. Spend your remaining years wisely.",
	"You return from the mist a little older, a little heavier—yet your paws still point upward."
]

@onready var label: Label = $DialogueLabel

func _ready() -> void:
	label.visible = false
	label.text = poetic_lines.pick_random()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Dog" or body.is_in_group("dog"):
		label.visible = true
		# Bonus: Save checkpoint so the player doesn't lose too much progress!
		if "checkpoint_pos" in body:
			body.checkpoint_pos = global_position + Vector2(0, -16)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Dog" or body.is_in_group("dog"):
		label.visible = false
