extends Node

# Export var
@export_enum("processing", "uploading", "wiping") var slotType : String

# Onready var

@onready var indicatorMesh := $mesh/slotIndicatorMesh

@onready var processingMat := preload("res://DevAssets/Materials/PalletOne/DM_Blue.tres")
@onready var uploadingMat := preload("res://DevAssets/Materials/PalletOne/DM_Yellow.tres")
@onready var wipingMat := preload("res://DevAssets/Materials/PalletOne/DM_BrightRed.tres")

@onready var panelSlot := $panelSlot
@onready var rackSlots: Array[Node] = [$rackSlots/rack1, $rackSlots/rack2, $rackSlots/rack3, $rackSlots/rack4, $rackSlots/rack5]

# Basic var

var rackAreaOff: bool

func _ready() -> void:
	setType()

func _process(_delta: float) -> void:
	checkPanel()

func checkPanel():
	var panelPresent := panelSlot.has_node("panel")
	if panelPresent == rackAreaOff:
		return
	rackAreaOff = panelPresent
	for rack in rackSlots:
		if rackAreaOff:
			rack.hideSlot()
		else:
			rack.showSlot()

func checkSlots() -> float:
	var base := 1.0
	var tier3 := 0

	for rack in rackSlots:
		if rack.slottedItem != null:
			match rack.slottedItem.tier:
				"tier1":
					base += 1.0
				"tier2":
					base += 2.0
				"tier3":
					base += 2.0
					tier3 += 1

	var multiplier = base * pow(1.25, tier3)
	return multiplier

func setType():
	match slotType:
		"processing":
			indicatorMesh.material_override = processingMat
			
			for rack in rackSlots:
				rack.slotType = "processingRack"
		"uploading":
			indicatorMesh.material_override = uploadingMat
			
			for rack in rackSlots:
				rack.slotType = "uploadingRack"
		"wiping":
			indicatorMesh.material_override = wipingMat
			
			for rack in rackSlots:
				rack.slotType = "wipingRack"
