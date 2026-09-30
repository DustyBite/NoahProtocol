extends Node

# Onready var

@onready var root = $"../.."
@onready var palletScene = preload("res://assets/TEMP/pallet/pallet.tscn")
@onready var palletSpot := $palletSpawner
@onready var cargoSpot := $cargoSpawner

# Basic var

func interact():
	if checkPallet():
		spawnPallet()
	else:
		swapPallet()

func spawnPallet():
	print("spawn")
	var spawnPal = palletScene.instantiate()
	root.add_child(spawnPal)
	spawnPal.global_transform = palletSpot.global_transform

func swapPallet():
	print("swap")

func checkPallet():
	var pallet = get_tree().get_node_in_group("pallet")
