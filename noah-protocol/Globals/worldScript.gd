extends Node3D
class_name WorldScript

# Const var


# Export var

@export var devMode: bool = false

# Onready var

@onready var player = $player

# basic Var

var saveDirectory = "My Games/Dead Frequency/NOAHProtocol/"
var SavePassword = "ALANALAMB"
var saveFile = "NoahProtocol_PreAlpha"

var palletArray: Array
var crateArray: Array
var cassetteArray: Array


func _onready():
	player.worldRoot = self
	
	if devMode:
		saveDirectory = "My Games/Dead Frequency/NOAHProtocol/Dev/"
		saveFile = "devSave1"

func getSaveDrectory() -> String:
	var userProfile = OS.get_environment("USERPROFILE")
	return userProfile + "/Documents/" + saveDirectory


func ensureSaveDirectory() -> void:
	var directory = getSaveDrectory()

	if not DirAccess.dir_exists_absolute(directory):
		DirAccess.make_dir_recursive_absolute(directory)


func save():
	ensureSaveDirectory()

	var savePath = getSaveDrectory() + saveFile
	
	updateWorldObjects()

	var saveData = {
		#GameData
		"gameVersion": "0.1",
		
		#GlobalsData
		"pointTotal": Globals.pointTotal,
		"cardsProcessed": Globals.cardsProcessed,
		
		#PlayerData
		"playerPos": [player.global_position.x, player.global_position.y ,player.global_position.z],
		"playerRot": [player.global_rotation.x, player.global_rotation.y, player.global_rotation.z],
		
		#palletData
		"totalPallets": palletArray.size(),
		
		#crateData
		"totalCrates": crateArray.size(),
		
		#cassetteData
		"totalCassettes": cassetteArray.size(),
	}

	var file = FileAccess.open_encrypted_with_pass(savePath, FileAccess.WRITE, SavePassword)

	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()
		print("Game saved to: ", savePath)

func load():
	var savePath = getSaveDrectory() + saveFile

	if not FileAccess.file_exists(savePath):
		print("No save file found.")
		return

	var file = FileAccess.open_encrypted_with_pass(savePath, FileAccess.READ, SavePassword)
	var saveData = JSON.parse_string(file.get_as_text())
	file.close()

	if saveData == null:
		print("Failed to read save file.")
		return
	
	var appliers = {
		#loading World Data
		"pointTotal": func(v) : Globals.pointTotal = v,
		"cardsProcessed": func(v) : Globals.cardsProcessed = v,
		
		#loading Player Data
		"playerPos": func(v) : player.global_position = Vector3(v[0],v[1],v[2]),
		"playerRot": func(v) : player.global_rotation = Vector3(v[0],v[1],v[2]),
		
		#load Object Data
		"totalPallets": func(v) : print("total Pallets = ", v),
		"totalCrates": func(v) : print("total Crates = ", v),
		"totalCassettes": func(v) : print("total Cassettes = ", v),
	}
	
	for key in appliers.keys():
		if saveData.has(key):
			appliers[key].call(saveData[key])
		else:
			print("missing save data for ", key)
	
	#print("Loaded save data: ", saveData)

func updateWorldObjects():
	
	palletArray.clear()
	var pallets = get_tree().get_nodes_in_group("pallet")
	for pallet in pallets:
		if pallet.get_parent() == self:
			palletArray.append(pallet)
	
	crateArray.clear()
	var crates = get_tree().get_nodes_in_group("crate")
	for crate in crates:
		if crate.get_parent() == self:
			crateArray.append(crate)
	
	cassetteArray.clear()
	var cassettes = get_tree().get_nodes_in_group("cassette")
	for cassette in cassettes:
		if cassette.get_parent() == self:
			cassetteArray.append(cassette)
