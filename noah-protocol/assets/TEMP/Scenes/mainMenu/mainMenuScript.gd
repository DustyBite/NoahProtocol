extends Control

var gameScene = preload("res://assets/TEMP/Scenes/BunkerTemp.tscn")

func _on_start_pressed() -> void:
	Globals.singleplayerMode = true
	get_tree().change_scene_to_packed(gameScene)

func _on_host_pressed() -> void:
	Globals.singleplayerMode = false
	Globals.launchMode = "host"
	get_tree().change_scene_to_packed(gameScene)

func _on_join_pressed() -> void:
	Globals.singleplayerMode = false
	Globals.launchMode = "client"
	get_tree().change_scene_to_packed(gameScene)

func _on_quit_pressed() -> void:
	get_tree().quit()
