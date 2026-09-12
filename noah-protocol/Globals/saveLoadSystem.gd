extends Node

const SAVEDIRECTORY = "My Games/Dead Frequency/NOAHProtocol/"
const SAVEFILE = "saveTEST.json"
const SAVEPASSWORD = "ALANALAMB"


func get_save_directory() -> String:
	var userProfile = OS.get_environment("USERPROFILE")
	return userProfile + "/Documents/" + SAVEDIRECTORY


func ensure_save_directory() -> void:
	var directory = get_save_directory()

	if not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)


func save():
	ensure_save_directory()

	var savePath = get_save_directory() + SAVEFILE

	var saveData = {
		"player_position": [0, 0, 0],
		"money": 100,
		"current_van": "van_01",
		"game_version": "0.1"
	}

	var file = FileAccess.open_encrypted_with_pass(savePath, FileAccess.WRITE, SAVEPASSWORD)

	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()
		print("Game saved to: ", savePath)

func load():
	var savePath = get_save_directory() + SAVEFILE

	if not FileAccess.file_exists(savePath):
		print("No save file found.")
		return

	var file = FileAccess.open_encrypted_with_pass(savePath, FileAccess.READ, SAVEPASSWORD)
	var saveData = JSON.parse_string(file.get_as_text())
	file.close()

	if saveData == null:
		print("Failed to read save file.")
		return

	print("Loaded save data: ", saveData)
