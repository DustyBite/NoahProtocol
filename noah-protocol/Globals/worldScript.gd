extends Node3D
class_name WorldScript

# Const var


# Export var

@export var devMode: bool = false

# Onready var

@onready var player = $player

#Spawnables
@onready var palletScene = preload("res://assets/TEMP/pallet/pallet.tscn")
@onready var crateScene = preload("res://assets/interactables/cartridge/cartridgeCrate.tscn")
@onready var cassetteScene = preload("res://assets/interactables/cartridge/cartridge.tscn")

@onready var drinkScene = preload("res://assets/interactables/consumables/eDrink.tscn")
@onready var foodScene = preload("res://assets/interactables/consumables/packFood.tscn")
# basic Var

var saveDirectory = "My Games/Dead Frequency/NOAHProtocol/"
var SavePassword = "ALANALAMB"
var saveFile = "NoahProtocol_PreAlpha"

var palletArray: Array
var crateArray: Array
var cassetteArray: Array
var drinkArray: Array
var foodArray: Array


func _onready():
	player.worldRoot = self
	
	if devMode:
		saveDirectory = "My Games/Dead Frequency/NOAHProtocol/Dev/"
		saveFile = "devSave1"

func _process(_delta: float) -> void:
	if Globals.unlockArray[8] == 1:
		$room/pingMachine.global_position = Vector3(-1,0,4.5)
	else:
		$room/pingMachine.global_position = Vector3(-1,-10,4.5)

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
		"type2Consumables": Globals.type2Consumables,
		"emails": Globals.avalibleEmail,
		"unlockArray": Globals.unlockArray,
		
		#PlayerData
		"playerPos": [player.global_position.x, player.global_position.y ,player.global_position.z],
		"playerRot": [player.global_rotation.x, player.global_rotation.y, player.global_rotation.z],
		"playerHunger": player.hunger,
		"playerEnergy": player.exhaustion,
		"playerSanity": player.sanity,
		
		#objectData
		"palletData": saveObjectData(palletArray, "pallet"),
		"crateData": saveObjectData(crateArray, "crate"),
		"cassetteData": saveObjectData(cassetteArray, "cassette"),
		"drinkData": saveObjectData(drinkArray, "drink"),
		"foodData": saveObjectData(foodArray, "food"),
	}

	var file = FileAccess.open_encrypted_with_pass(savePath, FileAccess.WRITE, SavePassword)

	if file:
		file.store_string(JSON.stringify(saveData))
		file.close()
		print("Game saved to: ", savePath)

func load():
	updateWorldObjects()
	
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
		"type2Consumables": func(v) : Globals.type2Consumables = v,
		"emails": func(v) : Globals.avalibleEmail = v,
		"unlockArray": func(v) : Globals.unlockArray = v,
		
		#loading Player Data
		"playerPos": func(v) : player.global_position = Vector3(v[0],v[1],v[2]),
		"playerRot": func(v) : player.global_rotation = Vector3(v[0],v[1],v[2]),
		"playerHunger": func(v) : player.hunger = v,
		"playerEnergy": func(v) : player.exhaustion = v,
		"playerSanity": func(v) : player.sanity = v,
		
		#load Object Data
		"palletData": func(v): spawnFromData(v, palletScene, palletArray, "pallet"),
		"crateData": func(v): spawnFromData(v, crateScene, crateArray, "crate"),
		"cassetteData": func(v): spawnFromData(v, cassetteScene, cassetteArray, "cassette"),
		"drinkData": func(v): spawnFromData(v, drinkScene, drinkArray, "drink"),
		"foodData": func(v): spawnFromData(v, foodScene, foodArray, "food"),
	}
	
	for key in appliers.keys():
		if saveData.has(key):
			appliers[key].call(saveData[key])
		else:
			print("missing save data for ", key)
	
	#print("Loaded save data: ", saveData)

func saveObjectData(objArray, objType):
	var data = []

	for obj in objArray:
		var entry = {
			"position": [obj.global_position.x, obj.global_position.y, obj.global_position.z],
			"rotation": [obj.global_rotation.x, obj.global_rotation.y, obj.global_rotation.z],
		}

		if objType == "cassette":
			entry["status"] = obj.status
		elif objType == "crate":
			entry["cardDataArray"] = obj.get_save_data()
		elif objType == "drink" or objType == "food" :
			entry["full"] = obj.full

		data.append(entry)

	return data


func spawnFromData(v, objScene, objArray, objType):
	if typeof(v) != TYPE_ARRAY:
		print("Wrong Format")
		return

	for obj in objArray:
		obj.queue_free()
	objArray.clear()

	for entity in v:
		var obj = objScene.instantiate()

		if objType == "crate":
			obj.apply_save_data(entity.get("cardDataArray", []))

		add_child(obj)

		var pos = entity["position"]
		var rot = entity["rotation"]
		obj.global_position = Vector3(pos[0], pos[1], pos[2])
		obj.global_rotation = Vector3(rot[0], rot[1], rot[2])

		if objType == "cassette":
			obj.status = entity.get("status", null)
		elif objType == "drink" or objType == "food" :
			obj.full = entity.get("full", null)

		objArray.append(obj)

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
	
	drinkArray.clear()
	var drinks = get_tree().get_nodes_in_group("drink")
	for drink in drinks:
		if drink.get_parent() == self:
			drinkArray.append(drink)
	
	foodArray.clear()
	var foods = get_tree().get_nodes_in_group("food")
	for food in foods:
		if food.get_parent() == self:
			foodArray.append(food)
