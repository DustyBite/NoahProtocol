extends InteractableDynamic

@export var lidOpen: bool = false

@onready var lidRotate := $lidRotate
var lidOpenRot: float = -1.5
var lidCloseRot: float  = 0.0
var lidTargetRot: float  = 0.0

@onready var cartridge := preload("res://assets/interactables/cartridge/cartridge.tscn")

@onready var crateColBox:= $CollisionShape3D
var cratecolClosed := .4
var cratecolOpen := .3

var cartridgeSlots: Array

func _ready() -> void:
	super._ready()
	
	getSlots()
	closeLid()

func getSlots():
	for cardSlot in $slotMarkers.get_children():
		cartridgeSlots.append(cardSlot)
		
		if cardSlot.has_method("spawnItem"):
			cardSlot.spawnItem(cartridge)

func _process(_delta: float) -> void:
	lidRotate.rotation.z = lerp(lidRotate.rotation.z, lidTargetRot, .1)

func getTotalPoints():
	var total = 0
	for cardSlot in cartridgeSlots:
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
	freeze = true
	lidOpen = true
	lidTargetRot = lidOpenRot
	
	for cardSlot in cartridgeSlots:
		cardSlot.InteractOn()
	
	crateColBox.shape.size.y = .3
	crateColBox.position.y = -.05 
	
	self.canDrag = false

func closeLid():
	freeze = false
	lidOpen = false
	lidTargetRot = lidCloseRot
	
	for cardSlot in cartridgeSlots:
		cardSlot.InteractOff()
	
	crateColBox.shape.size.y = .4
	crateColBox.position.y = 0
	
	self.canDrag = true
