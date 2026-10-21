extends InteractableDynamic

# EXPORT VAR

@export var spawnCassettes : bool = true

# ONREADY VAR

@onready var cassettes := preload("res://assets/interactables/cassetteItems/cassette/cartridge.tscn")
@onready var crateColBox:= $CollisionShape3D
@onready var lidRotate := $lidRotate

# BASIC VAR

var lidOpenRot: float = -1.5
var lidCloseRot: float  = 0.0
var lidTargetRot: float  = 0.0

var lidOpen: bool = false
var cratecolClosed := .4
var cratecolOpen := .3

var cassettesSlots: Array
var cardData: Array = []

var interacting: bool = false

func _ready() -> void:
	super._ready()

	getSlots()
	
	crateColBox.shape = crateColBox.shape.duplicate(true)
	
	if cardData.is_empty():
		for i in cassettesSlots.size():
			cardData.append({"card": 1 if spawnCassettes else 0, "status": null, "caseColor": Color(), "handleColor": Color()})

	loadCassettes()
	spawnCassettes = false
	closeLid()

func getSlots():
	for cardSlot in $slotMarkers.get_children():
		cassettesSlots.append(cardSlot)
	return

func loadCassettes():
	for i in range(cassettesSlots.size()):
		var cardSlot = cassettesSlots[i]
		if cardSlot.slottedItem != null:
			continue  # already occupied, don't double-spawn
		var data = cardData[i]
		if cardSlot.has_method("loadCard"):
			cardSlot.loadCard(cassettes, data.card == 1, data.status, data.caseColor, data.handleColor)
	return

func deloadCassettes():
	for i in range(cassettesSlots.size()):
		var cardSlot = cassettesSlots[i]
		var card = cardSlot.slottedItem
		if card != null:
			cardData[i] = {"card": 1, "status": card.status, "caseColor": card.caseColor, "handleColor": card.handleColor}
		else: 
			cardData[i] = {"card": 0, "status": null, "caseColor": Color(), "handleColor": Color()}
		if cardSlot.has_method("deloadItem"):
			cardSlot.deloadCard()
	return

func get_save_data() -> Array:
	for i in range(cassettesSlots.size()):
		var card = cassettesSlots[i].slottedItem
		if card != null:
			cardData[i] = {"card": 1, "status": card.status}
		# else: leave cardData[i] untouched — deloadCassettes() already recorded this slot correctly
	return cardData.duplicate(true)

func apply_save_data(data: Array) -> void:
	cardData = data.duplicate(true)

func _process(_delta: float) -> void:
	lidRotate.rotation.z = lerp(lidRotate.rotation.z, lidTargetRot, .1)

func getTotalPoints():
	var total = 0
	for i in range(cassettesSlots.size()):
		var cardSlot = cassettesSlots[i]
		if cardSlot.slottedItem == null:
			return
		var status = cardData[i].status
		match status:
			"loaded": total += -20
			"processing": total +=  0
			"clear": total +=  15
			"corrupted": total +=  -5
	return total

func interact(_body):
	if placed or interacting:
		return
	
	if !lidOpen:
		openLid()
	else:
		closeLid()

func openLid():
	interacting = true
	loadCassettes()
	
	freeze = true
	lidOpen = true
	lidTargetRot = lidOpenRot
	
	for cardSlot in cassettesSlots:
		cardSlot.InteractOn()
	
	crateColBox.shape.size.y = .3
	crateColBox.position.y = -.1
	
	self.canDrag = false
	
	interacting = false

func closeLid():
	interacting = true
	
	freeze = false
	lidOpen = false
	lidTargetRot = lidCloseRot
	
	for cardSlot in cassettesSlots:
		cardSlot.InteractOff()
	
	crateColBox.shape.size.y = .5
	crateColBox.position.y = 0
	
	self.canDrag = true
	
	await get_tree().create_timer(0.5).timeout
	deloadCassettes()
	
	interacting = false
