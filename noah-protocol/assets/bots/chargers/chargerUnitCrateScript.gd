extends Node3D

# Export vars
@export var assignedBot: Node
@export var processStation: Node       # the processing station (has .crateProcessor)

@export_category("area3Ds")
@export var roomArea: Area3D

@export_category("storagePosMarkers")
@export var unpackStations: Node

# Base vars
var checkTimer: float = 1.0
var stage: String = "idle"   # idle, fetching, loading, waiting, returning
var unpacking: Array = []
var claimedCrates: Array = []   # crates the bot is already working on
var reservedSlots: Array = []   # slots something is already headed for
var jobCrates: Array = []       # the 2 crates in the current job
var moves: Array = []           # queue of {crate, slot} grabs still to do

const CRATES_PER_JOB := 2
const UNPACK_RADIUS := 0.6      # how close a crate must be to count as "at" a slot


func _ready() -> void:
	if unpackStations != null:
		for slot in unpackStations.get_children():
			unpacking.append(slot)


func _process(delta: float) -> void:
	if checkTimer > 0:
		checkTimer -= delta
		return
	checkTimer = 1.0

	if assignedBot.currentTask == "idle":
		tick()


# --- Main loop: runs once a second, only when the bot is idle ---

func tick() -> void:
	match stage:
		"idle":
			startJob()

# --- Starting a job ---

func startJob() -> void:
	# 1. stray crates first
	var stray = findStrayCrate()
	if stray != null:
		assignedBot.targetObj = stray
		return

	# 2. otherwise take crates from the unpacking station
	var crates: Array = []
	var sources: Array = []
	for slot in unpacking:
		var crate = crateAt(slot)
		if crate != null:
			crates.append(crate)
			sources.append(slot)
			if crates.size() == CRATES_PER_JOB:
				break
	if crates.is_empty():
		return

	# need one free processor slot per crate
	var targets: Array = []
	for slot in processStation.crateProcessor.crateSlots:
		if slot.slottedItem == null and !reservedSlots.has(slot):
			targets.append(slot)
			if targets.size() == crates.size():
				break
	if targets.size() < crates.size():
		return  # processor is busy, try again next tick

	jobCrates = crates
	for i in crates.size():
		claimedCrates.append(crates[i])
		reservedSlots.append(targets[i])
		moves.append({"crate": crates[i], "slot": targets[i]})
	stage = "loading"
	runNextMove()


func runNextMove() -> void:
	if moves.is_empty():
		return
	var move = moves.pop_front()
	assignedBot.assignTask(move.crate, move.slot, "grabObject")


# --- Waiting and returning ---

func allProcessed(crates: Array) -> bool:
	for crate in crates:
		for slot in crate.cassettesSlots:
			var card = slot.slottedItem
			if card != null and (card.status == "loaded" or card.status == "processing"):
				return false
	return true


func finishJob() -> void:
	claimedCrates.clear()
	reservedSlots.clear()
	jobCrates.clear()
	stage = "idle"


# --- Finding things ---

func findStrayCrate():
	var closest = null
	for body in roomArea.get_overlapping_bodies():
		if "type" in body and body.type == "crate" and body.slot == null and !claimedCrates.has(body):
			if closest == null or global_position.distance_to(body.global_position) < global_position.distance_to(closest.global_position):
				closest = body
	return closest


func crateAt(slot):
	for body in roomArea.get_overlapping_bodies():
		if "type" in body and body.type == "crate" and !claimedCrates.has(body):
			if body.global_position.distance_to(slot.global_position) < UNPACK_RADIUS:
				return body
	return null
