extends Control
var player

func _on_return_pressed() -> void:
	player.togglePause()

func _on_mainmenu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/TEMP/Scenes/mainMenu/MainMenu.tscn")

func _on_quitgame_pressed() -> void:
	get_tree().quit()

func _on_load_pressed() -> void:
	SaveLoadSystem.load()

func _on_save_pressed() -> void:
	SaveLoadSystem.save()
