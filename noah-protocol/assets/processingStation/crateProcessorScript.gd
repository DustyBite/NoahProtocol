extends Node3D

@onready var rack := $rack

var automating : bool = false
var automationSpeed : float = 0.0

var crateSlots: Array

func _ready() -> void:
	getSlots()

func _process(_delta: float) -> void:
	checkSlots()
	
	checkRack()

func checkRack():
	if rack.slottedItem != null:
		automating = true
	else:
		automating = false

func getSlots():
	for crateSlot in $slots.get_children():
		crateSlots.append(crateSlot)

func checkSlots():
	var top := -1
	for i in crateSlots.size():
		if crateSlots[i].slottedItem != null:
			top = i

	for i in crateSlots.size():
		var slot = crateSlots[i]
		if slot.slottedItem != null:
			if i == top:
				slot.InteractOn()
				slot.interactable = true
			else:
				slot.InteractOff()
				slot.interactable = false
		elif i == top + 1:
			slot.showSlot()
		else:
			slot.hideSlot()
