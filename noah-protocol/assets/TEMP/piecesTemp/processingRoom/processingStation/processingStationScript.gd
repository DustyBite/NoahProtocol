extends Node

@onready var cardSlot := $slot
var slottedCard: bool = false
var validCard: bool = true
var activeProcess: bool = false
var card

@onready var screenLabel := $SubViewport/Control/Panel/Label
@onready var progressBar := $SubViewport/Control/Panel/ProgressBar


var currentTxt: String
var defaultTxt: String = "INPUT CASSETTE . . ."
var validTxt: String = "VALID CASSETTE FOUND. PRESS BUTTON TO PROCESS"
var invalidTxt: String = "INVALID/CORRUPTED CASSETTE FOUND. PLEASE REMOVE"
var processingTxt: String = "PROCESSING DATA . . ."
var uploadigTxt: String = "UPLOADING DATA . . ."
var wipingTxt: String = "WIPING CASSETTE . . ."
var finishedTxt: String = "CASSETTE PROCESSED. PLEASE REMOVE"

func _ready() -> void:
	currentTxt = defaultTxt

func _process(_delta: float) -> void:
	checkSlot()
	
	screenLabel.text = currentTxt

func checkSlot():
	if cardSlot.slottedItem != null and card != cardSlot.slottedItem:
		card = cardSlot.slottedItem
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
	elif cardSlot.slottedItem == null:
		currentTxt = defaultTxt
		progressBar.value = 0
		card = null
		slottedCard = false
		validCard = true

func interact():
	if !slottedCard or !validCard or activeProcess:
		return
	activeProcess = true
	cardSlot.InteractOff()
	await processCard()
	await uploadData()
	await wipeCard()
	cardSlot.InteractOn()
	activeProcess = false

func processCard():
	card.status = "processing"
	currentTxt = processingTxt
	var elapsed = 0.0
	var duration = randf_range(4.5,5.5)
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
	var duration = randf_range(4.5,5.5)
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var progress = clamp((elapsed / duration) * 100.0, 0.0, 100.0)
		progressBar.value = progress
		await get_tree().process_frame
	progressBar.value = 100.0
	Globals.pointTotal += 25

func wipeCard():
	currentTxt = wipingTxt
	var elapsed = 0.0
	var duration = randf_range(4.5,5.5)
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
