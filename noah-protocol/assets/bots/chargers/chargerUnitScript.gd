extends Node3D
# Export Vars

@export var assignedBot: Node

@export_category("area3Ds")
@export var storageRoomArea: Area3D
@export var transitionRoomArea: Area3D
@export var containerArea: Area3D
@export_category("storagePosMarkers")
@export var unpackStations: Node
@export var storagePosA: Node
@export var storagePosB: Node

# Base vars
var checkTimer: float = 1.0
var UnprocessedPalletArray: Array
var botIdle: bool = true
var unpacking: Array
var storageA: Array
var storageB: Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for slot in unpackStations.get_children():
		unpacking.append(slot)
	
	for slot in storagePosA.get_children():
		storageA.append(slot)
	
	for slot in storagePosB.get_children():
		storageB.append(slot)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if checkTimer <= 0:
		checkTimer = 1.0
		if assignedBot.currentTask == "idle":
			getTask()
	else:
		checkTimer -= delta
	
	#return
	

func checkArea(area3D, state):
	for body in area3D.get_overlapping_bodies():
		if body.type == "pallet":
			if body.crateState == state:
				if !UnprocessedPalletArray.has(body):
					UnprocessedPalletArray.append(body)

func getTask():
	if UnprocessedPalletArray.is_empty():
		checkArea(containerArea, "unprocessed")
		return
	elif !UnprocessedPalletArray.is_empty():
		var closestPallet = null
		for pallet in UnprocessedPalletArray:
			if closestPallet == null or global_position.distance_to(closestPallet.global_position) > global_position.distance_to(pallet.global_position):
				closestPallet = pallet
		
		var emptySlot = null
		for slot in unpacking:
			if slot.occupied == false:
				emptySlot = slot
				slot.occupied = true
				break
		
		if emptySlot == null:
			for slot in storageA:
				if slot.occupied == false:
					emptySlot = slot
					slot.occupied = true
					break
		
		if emptySlot == null:
			for slot in storageB:
				if slot.occupied == false:
					emptySlot = slot
					slot.occupied = true
					break
		
		assignedBot.assignTask(closestPallet, emptySlot, "grabObject")
		UnprocessedPalletArray.erase(closestPallet)
		emptySlot = null
