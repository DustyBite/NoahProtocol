extends Node

# Onready var

@onready var root = $"../.."
@onready var palletScene = preload("res://assets/TEMP/pallet/pallet.tscn")
@onready var palletSpot := $palletSpawner
@onready var cargoSpot := $cargoSpawner

# Basic var

var pallet = null

func interact():
	checkPallet()
	if pallet == null:
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
	pallet = get_tree().get_first_node_in_group("pallet")
