extends InteractableDynamic

# EXPORT VAR

@export var spawnCassettes : bool = true

# ONREADY VAR

@onready var cassettes := preload("res://assets/interactables/cartridge/cartridge.tscn")
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
var cassetteArray: Array

func _ready() -> void:
	super._ready()
	
	getSlots()
	loadCassettes()
	spawnCassettes = false
	closeLid()

func getSlots():
	for cardSlot in $slotMarkers.get_children():
		cassettesSlots.append(cardSlot)
	return

func loadCassettes():
	for cardSlot in cassettesSlots:
		if cardSlot.has_method("loadItem"):
			cardSlot.loadItem(cassettes,spawnCassettes)
	
	return

func deloadCassettes():
	for cardSlot in cassettesSlots:
		if cardSlot.has_method("deloadItem"):
			cardSlot.deloadItem()
	
	return

func _process(_delta: float) -> void:
	lidRotate.rotation.z = lerp(lidRotate.rotation.z, lidTargetRot, .1)

func getTotalPoints():
	var total = 0
	for cardSlot in cassettesSlots:
		var card = cardSlot.slottedItem
		if card != null and card.has_method("getPoints"):
			total += card.getPoints()
	return total

func interact(_body):
	if placed:
		return
	
	if !lidOpen:
		openLid()
	else:
		closeLid()

func openLid():
	loadCassettes()
	
	freeze = true
	lidOpen = true
	lidTargetRot = lidOpenRot
	
	for cardSlot in cassettesSlots:
		cardSlot.InteractOn()
	
	crateColBox.shape.size.y = .3
	crateColBox.position.y = -.05 
	
	self.canDrag = false

func closeLid():
	
	freeze = false
	lidOpen = false
	lidTargetRot = lidCloseRot
	
	for cardSlot in cassettesSlots:
		cardSlot.InteractOff()
	
	crateColBox.shape.size.y = .4
	crateColBox.position.y = 0
	deloadCassettes()
	
	self.canDrag = true
