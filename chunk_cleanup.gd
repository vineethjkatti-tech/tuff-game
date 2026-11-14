extends TileMapLayer

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(3.0).timeout
	if not $VisibleOnScreenNotifier2D.is_on_screen():
		queue_free()


func _on_screen_exited() -> void:
	pass # Replace with function body.
