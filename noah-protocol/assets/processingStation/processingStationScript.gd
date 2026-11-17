extends Node

# Onready vars

@onready var cardSlotA := $processingSlots/processingSlotA
#@onready var cardSlotB := $processingSlots/processingSlotB
#@onready var cardSlotC := $processingSlots/processingSlotC

@onready var processRack := $processSlot
@onready var uploadRack := $uploadSlot
@onready var wipeRack := $wipeSlot

@onready var crateProcessor := $crateProcessor

@onready var screenLabel := $SubViewport/Control/Panel/Label
@onready var progressBar := $SubViewport/Control/Panel/ProgressBar

# Basic vars

var slottedCard: bool = false
var validCard: bool = true
var activeProcess: bool = false
var cardA
var cardB
var cardC

var currentTxt: String
var defaultTxt: String = "INPUT CASSETTE . . ."
var validTxt: String = "VALID CASSETTE FOUND. PRESS BUTTON TO PROCESS"
var invalidTxt: String = "INVALID/CORRUPTED CASSETTE FOUND. PLEASE REMOVE"
var processingTxt: String = "PROCESSING DATA . . ."
var uploadigTxt: String = "UPLOADING DATA . . ."
var wipingTxt: String = "WIPING CASSETTE . . ."
var finishedTxt: String = "CASSETTE PROCESSED. PLEASE REMOVE"

var processSpeed: int = 1
var uploadSpeed: int = 1
var wipeSpeed: int = 1

var processing: bool = false
var checkInterval := 2.0  # seconds between checks
var checkTimer := 0.0

func _ready() -> void:
	currentTxt = defaultTxt

func _process(delta: float) -> void:
	screenLabel.text = currentTxt
	
	automation(delta)

func automation(delta):
	if processing:
		return

	checkTimer += delta
	if checkTimer < checkInterval:
		return
	checkTimer = 0.0

	if crateProcessor.automating:
		for i in range(crateProcessor.crateSlots.size() - 1, -1, -1):
			var crate = crateProcessor.crateSlots[i].slottedItem
			if crate != null:
				if firstValidSlot(crate) != null:
					if !crate.lidOpen:
						crate.openLid()
					automateCrate(crate)
				elif crate.lidOpen:
					crate.closeLid()
				break

func firstValidSlot(crate):
	for slot in crate.cassettesSlots:
		var card = slot.slottedItem
		if card != null and (card.status == "loaded" or card.status == "processing"):
			return slot
	return null

func automateCrate(crate):
	while crateProcessor.automating:
		var crateSlot = firstValidSlot(crate)
		if crateSlot == null:
			break
		var card = crateSlot.slottedItem
		moveCard(card, cardSlotA)
		await checkSlots(cardSlotA, cardA)
		moveCard(card, crateSlot)
		checkSlots(cardSlotA, cardA)
	if crate.lidOpen:
		crate.closeLid()

func moveCard(card, targetSlot):
	var oldSlot = card.slot
	if oldSlot != null and oldSlot != targetSlot:
		oldSlot.slottedItem = null
	targetSlot.slotItem(card)

func checkUpgrades():
	print(processRack.checkSlots())
	processSpeed = processRack.checkSlots()
	uploadSpeed = uploadRack.checkSlots()
	wipeSpeed = wipeRack.checkSlots()

func checkSlots(slot, card):
	if processing:
		return
	
	if slot.slottedItem != null and card != slot.slottedItem:
		checkUpgrades()
		
		processing = true
		
		card = slot.slottedItem
		slottedCard = true
		
		match card.status:
			"loaded":
				currentTxt = validTxt
			"processing":
				currentTxt = validTxt
			"clear":
				currentTxt = finishedTxt
				return
			"corrupted":
				currentTxt = invalidTxt
				return
		
		slot.InteractOff()
		await processCard(card)
		await uploadData()
		await wipeCard(card)
		slot.InteractOn()
		
		processing = false
		
	elif slot.slottedItem == null:
		currentTxt = defaultTxt
		progressBar.value = 0
		card = null
		slottedCard = false
		validCard = true

func interact():
	checkSlots(cardSlotA, cardA)
	#checkSlots(cardSlotB, cardB)
	#checkSlots(cardSlotC, cardC)

func processCard(card):
	card.status = "processing"
	currentTxt = processingTxt
	var elapsed = 0.0
	var duration = randf_range(4.5,5.5) / processSpeed
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var progress = clamp((elapsed / duration) * 100.0, 0.0, 100.0)
		card.processProgress = progress
		progressBar.value = progress
		await get_tree().process_frame
	card.processProgress = 100.0
	progressBar.value = 100.0
	Globals.pointTotal += 10

func uploadData():
	currentTxt = uploadigTxt
	var elapsed = 0.0
	var duration = randf_range(4.5,5.5) / uploadSpeed
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var progress = clamp((elapsed / duration) * 100.0, 0.0, 100.0)
		progressBar.value = progress
		await get_tree().process_frame
	progressBar.value = 100.0
	Globals.pointTotal += 25

func wipeCard(card):
	currentTxt = wipingTxt
	var elapsed = 0.0
	var duration = randf_range(4.5,5.5) / wipeSpeed
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var progress = clamp((elapsed / duration) * 100.0, 0.0, 100.0)
		card.wipeProgress = progress
		progressBar.value = progress
		await get_tree().process_frame
	card.wipeProgress = 100.0
	progressBar.value = 100.0
	card.status = "clear"
	
	currentTxt = finishedTxt
	Globals.cardsProcessed += 1
	Globals.pointTotal += 50
