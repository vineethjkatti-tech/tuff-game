extends StaticBody2D

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Wait 2 seconds after leaving the screen so it doesn't vanish if you fall slightly
	await get_tree().create_timer(2.0).timeout
	if not $VisibleOnScreenNotifier2D.is_on_screen():
		queue_free()
