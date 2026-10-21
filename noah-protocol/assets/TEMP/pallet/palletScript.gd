extends InteractableDynamicOld

# Export vars

@export var cratesPerLevel: int = 3

# Onready vars

@onready var crate := preload("res://assets/interactables/cassetteItems/crate/cartridgeCrate.tscn")

# basic Vars

var crateSlots: Array
var crateState: String = "unprocessed"

func _ready() -> void:
	super._ready()
	
	getSlots()
	checkSlots()
	
	await get_tree().create_timer(0.5).timeout
	freeze = true

func _process(_delta: float) -> void:
	checkSlots()

func getTotalPoints() -> int:
	var total = 0
	for crateSlot in crateSlots:
		var crat = crateSlot.slottedItem
		if crat != null:
			total += crat.getTotalPoints()
	return total

func levelOf(index):
	return floori(float(index) / max(cratesPerLevel, 1))

func checkSlots():
	var topIndex = -1
	for i in range(crateSlots.size() - 1, -1, -1):
		if crateSlots[i].slottedItem != null:
			topIndex = i
			break
	
	var topLevel = -1 if topIndex == -1 else levelOf(topIndex)
	
	var placeLevel = 0
	if topLevel >= 0:
		placeLevel = topLevel
		var topLevelFull = true
		for i in range(crateSlots.size()):
			if levelOf(i) == topLevel and crateSlots[i].slottedItem == null:
				topLevelFull = false
				break
		if topLevelFull:
			placeLevel = topLevel + 1

	for i in range(crateSlots.size()):
		var craSlot = crateSlots[i]
		var level = levelOf(i)

		if craSlot.slottedItem != null:
			if level == topLevel:
				craSlot.InteractOn()
			else:
				craSlot.InteractOff()
		else:
			if level == placeLevel:
				craSlot.showSlot()
			else:
				craSlot.hideSlot()

func getSlots():
	for crateSlot in $crateSlots.get_children():
		crateSlots.append(crateSlot)
		
		if crateSlot.has_method("loadItem"):
			crateSlot.loadItem(crate,null)
