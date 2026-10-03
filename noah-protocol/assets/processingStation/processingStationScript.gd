extends Node

# Onready vars

@onready var cardSlotA := $processingSlots/processingSlotA
@onready var cardSlotB := $processingSlots/processingSlotB
@onready var cardSlotC := $processingSlots/processingSlotC

@onready var processUpgrade := $upgradeSlots/processSlot
@onready var uploadUpgrade := $upgradeSlots/uploadSlot
@onready var wipeUpgrade := $upgradeSlots/wipeSlot

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
var processUpgradeCard
var uploadUpgradeCard
var wipeUpgradeCard

func _ready() -> void:
	currentTxt = defaultTxt

func _process(_delta: float) -> void:
	screenLabel.text = currentTxt
	
	checkUpgrades()

func checkUpgrades():
	if processUpgrade.slottedItem != null and processUpgradeCard != processUpgrade.slottedItem:
		processUpgradeCard = processUpgrade.slottedItem
		processSpeed = processUpgradeCard.speedModifer
	
	if uploadUpgrade.slottedItem != null and uploadUpgradeCard != uploadUpgrade.slottedItem:
		uploadUpgradeCard = uploadUpgrade.slottedItem
		uploadSpeed = uploadUpgradeCard.speedModifer
	
	if wipeUpgrade.slottedItem != null and wipeUpgradeCard != wipeUpgrade.slottedItem:
		wipeUpgradeCard = wipeUpgrade.slottedItem
		wipeSpeed = wipeUpgradeCard.speedModifer

func checkSlots(slot, card):
	if slot.slottedItem != null and card != slot.slottedItem:
		card = slot.slottedItem
		slottedCard = true
		
		match card.status:
			"loaded":
				currentTxt = validTxt
			"processing":
				currentTxt = validTxt
			"clear":
				currentTxt = finishedTxt
			"corrupted":
				currentTxt = invalidTxt
		
		slot.InteractOff()
		await processCard(card)
		await uploadData()
		await wipeCard(card)
		slot.InteractOn()
		
	elif slot.slottedItem == null:
		currentTxt = defaultTxt
		progressBar.value = 0
		card = null
		slottedCard = false
		validCard = true

func interact():
	checkSlots(cardSlotA, cardA)
	checkSlots(cardSlotB, cardB)
	checkSlots(cardSlotC, cardC)

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
