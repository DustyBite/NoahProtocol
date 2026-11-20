extends Node

# Export vars

@export var checkInterval: float = 1.0

# Onready vars

@onready var palletPosMarker := $unpackSlotMarker
@onready var unprocessedPallet := $unprocessedPallet
@onready var processedSlots := $processedSlots
@onready var unprocessedSlots := $unprocessedSlots

# Basic vars

var checkTimer: float = 0.0

var pallet = null

func _process(delta: float) -> void:

	checkTimer += delta
	if checkTimer < checkInterval:
		return
	checkTimer = 0.0
	
	refillUnprocessedSlots()
	
	if pallet == null:
		return
	
	unloadDeliveredPallet()
	loadProcessedCrates()

func refillUnprocessedSlots() -> void:
	var target = firstEmpty(unprocessedSlots.get_children())
	if target == null:
		return

	var source = topOccupied(unprocessedPallet.crateSlots)
	if source != null:
		moveCrate(source, target)

func unloadDeliveredPallet() -> void:
	var source = topOccupied(pallet.crateSlots)
	if source == null:
		return

	var target = firstEmpty(unprocessedSlots.get_children())
	if target == null:
		target = firstEmpty(unprocessedPallet.crateSlots)

	if target != null:
		moveCrate(source, target)

func loadProcessedCrates() -> void:
	var source = firstOccupied(processedSlots.get_children())
	var target = firstEmpty(pallet.crateSlots)
	if source != null and target != null:
		moveCrate(source, target)

func moveCrate(from, to) -> void:
	var crate = from.slottedItem
	from.clearSlot()
	to.slotItem(crate)

func firstEmpty(slots: Array):
	for s in slots:
		if s.slottedItem == null:
			return s
	return null

func firstOccupied(slots: Array):
	for s in slots:
		if s.slottedItem != null:
			return s
	return null

func topOccupied(slots: Array):
	for i in range(slots.size() - 1, -1, -1):
		var crate = slots[i].slottedItem
		if firstValidSlot(crate):
			return slots[i]
	return null

func firstValidSlot(crate):
	if crate == null:
		return
	
	for slot in crate.cassettesSlots:
		var card = slot.slottedItem
		if card != null and (card.status == "loaded" or card.status == "processing"):
			return slot
	return null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is palletObj:
		pallet = body

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == pallet:
		pallet = null
