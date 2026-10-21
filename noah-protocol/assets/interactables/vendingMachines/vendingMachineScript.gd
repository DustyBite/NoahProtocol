extends Node

# Enum

# Export var

@export var consumableScene : PackedScene
@export_enum("food", "drink") var consumableSet: String

@export_group("Text")
@export var mainText: String
@export var typeALabel1: String
@export var typeALabel2: String
@export var typeBLabel1: String
@export var typeBLabel2: String

# Onready var

@onready var displaySlotsA := $displaySpotsA
@onready var displaySlotsB := $displaySpotsB
@onready var spawnSpot := $spawnSpot

# Basic var

var worldRoot

func _ready() -> void:
	worldRoot = get_tree().current_scene
	updateDisplay()

func _process(_delta: float) -> void:
	if Globals.type2Consumables:
		updateText($SubViewportB/Control/Panel/typeBLabel1, typeBLabel1)
		updateText($SubViewportB/Control/Panel/typeBLabel2, typeBLabel2)

func updateDisplay():
	if consumableScene == null:
		return
	
	for slot in displaySlotsA.get_children():
		var disCon = consumableScene.instantiate()
		disCon.place()
		slot.add_child(disCon)
	
	for slot in displaySlotsB.get_children():
		var disCon = consumableScene.instantiate()
		disCon.place()
		disCon.consumeType = "B"
		disCon.updateConsumeType()
		slot.add_child(disCon)
	
	updateText($SubViewportMain/Control/Panel/mainScreenLabel, mainText)
	updateText($SubViewportA/Control/Panel/typeALabel1, typeALabel1)
	updateText($SubViewportA/Control/Panel/typeALabel2, typeALabel2)
	updateText($SubViewportB/Control/Panel/typeBLabel1, "LOCKED")
	updateText($SubViewportB/Control/Panel/typeBLabel2, "LOCKED")
	

func updateText(label, text):
	if text == "":
		return
	
	label.text = text

func interactA():
	if consumableSet == "drink":
		if worldRoot.maxFreeDrink > 0:
			worldRoot.maxFreeDrink -= 1
		else:
			return
	elif consumableSet == "food":
		if worldRoot.maxFreeFood > 0:
			worldRoot.maxFreeFood -= 1
		else:
			return
	
	var disCon = consumableScene.instantiate()
	var root = get_tree().current_scene
	
	root.add_child(disCon)
	disCon.consumeType = "A"
	disCon.updateConsumeType()
	
	disCon.global_position = spawnSpot.global_position

func interactB():
	if !Globals.type2Consumables or Globals.pointTotal <= 25:
		return
	
	Globals.pointTotal -= 25
	
	var disCon = consumableScene.instantiate()
	var root = get_tree().current_scene
	
	root.add_child(disCon)
	disCon.consumeType = "B"
	disCon.updateConsumeType()
	
	disCon.global_position = spawnSpot.global_position
