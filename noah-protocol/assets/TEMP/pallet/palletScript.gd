extends InteractableDynamic

var crateSlots: Array

@onready var crate := preload("res://assets/interactables/cartridge/cartridgeCrate.tscn")


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
		total += crat.getTotalPoints()
	return total

func checkSlots():
	var topIndex = -1
	for i in range(crateSlots.size() - 1, -1, -1):
		if crateSlots[i].slottedItem != null:
			topIndex = i
			break
	
	for i in range(crateSlots.size()):
		var craSlot = crateSlots[i]
		
		if craSlot.slottedItem != null:
			if i == topIndex:
				craSlot.InteractOn()
			else:
				craSlot.InteractOff()
		else:
			if i == topIndex + 1:
				craSlot.showSlot()
			else:
				craSlot.hideSlot()

func getSlots():
	for crateSlot in $crateSlots.get_children():
		crateSlots.append(crateSlot)
		
		if crateSlot.has_method("spawnItem"):
			crateSlot.spawnItem(crate)
