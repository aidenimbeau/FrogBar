extends Control

func _on_start_button_button_up() -> void:
	get_tree().change_scene_to_file("res://main_level.tscn")