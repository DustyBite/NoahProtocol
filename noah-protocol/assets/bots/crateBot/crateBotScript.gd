extends botBase
class_name crateBot

@export_group("Crate Handling")
@export var carrySlots: Array[ItemSlot]   # the bot's 2 slots, drag them in
@export var grabDistance: float = 0.8      # how close to get before grabbing
@export var dropDistance: float = 0.8      # how close to get before dropping

var baseMoveSpeed: float
var baseRotationSpeed: float


func _ready() -> void:
	super._ready()
	baseMoveSpeed = moveSpeed
	baseRotationSpeed = rotationSpeed


signal taskFinished

func runTask(delta) -> void:
	match currentTask:
		"grab":
			if isAtTarget(targetObj, grabDistance):
				location = "grab"
				if faceTarget(targetObj, delta) and grabCrate(targetObj):
					finishTask()
			else:
				startPathTo(targetObj)
		"drop":
			if isAtTarget(targetLocation, dropDistance):
				location = "drop"
				if faceTarget(targetLocation, delta) and dropCrate(targetObj, targetLocation):
					finishTask()
			else:
				startPathTo(targetLocation)

func finishTask() -> void:
	clearPath()
	targetObj = null
	targetLocation = null
	currentTask = "idle"
	taskFinished.emit()   # keep this last


# --- Grab and drop ---

func grabCrate(crate) -> bool:
	var carrySlot = freeCarrySlot()
	if carrySlot == null:
		return false

	# forget the slot it's leaving
	var oldSlot = crate.slot
	if oldSlot != null and oldSlot.slottedItem == crate:
		oldSlot.slottedItem = null

	carrySlot.slotItem(crate)
	carrySlot.InteractOff()   # player can't grab it off the bot
	updateSpeed()
	return true


func dropCrate(crate, target) -> bool:
	# take it out of whichever carry slot holds it
	for slot in carrySlots:
		if slot.slottedItem == crate:
			slot.slottedItem = null

	if target is ItemSlot:
		target.slotItem(crate)
		target.InteractOn()
	else:
		crate.reparent(get_tree().current_scene)
		crate.place()

	updateSpeed()
	return true


# --- Helpers ---

func freeCarrySlot():
	for slot in carrySlots:
		if slot.slottedItem == null:
			return slot
	return null


func heldCount() -> int:
	var count := 0
	for slot in carrySlots:
		if slot.slottedItem != null:
			count += 1
	return count


func updateSpeed() -> void:
	var factor := 0.5 if heldCount() > 0 else 1.0
	moveSpeed = baseMoveSpeed * factor
	rotationSpeed = baseRotationSpeed * factor


# Turns toward the target. Returns true once facing it.
func faceTarget(target: Node3D, delta) -> bool:
	var dir = target.global_position - global_position
	var angleRad = atan2(dir.x, dir.z)
	var currentRad = deg_to_rad(rotation_degrees.y)
	if abs(angle_difference(angleRad, currentRad)) > 0.05:
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
		return false
	return true
