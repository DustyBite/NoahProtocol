extends InteractableDynamic

@export_enum("processingRack", "uploadingRack", "wipingRack", "automationRack") var slotType : String
@export_enum("tier1", "tier2", "tier3") var tier : String

@export var multipler: float = 1.0

# Onready vars

@onready var blinkIndicatorMesh := $mesh/blinkIndicator
@onready var slotIndicatorMesh := $mesh/slotIndicator
@onready var tierIndicatorMesh := $mesh/tierIndicator

#Mats
@onready var blinkOnMat := preload("res://DevAssets/Materials/PalletOne/DM_Lime.tres")
@onready var blinkOffMat := preload("res://DevAssets/Materials/PalletOne/DM_Grey.tres")

@onready var processingMat := preload("res://DevAssets/Materials/PalletOne/DM_Blue.tres")
@onready var uploadingMat := preload("res://DevAssets/Materials/PalletOne/DM_Yellow.tres")
@onready var wipingMat := preload("res://DevAssets/Materials/PalletOne/DM_BrightRed.tres")
@onready var automationMat := preload("res://DevAssets/Materials/PalletOne/DM_Cyan.tres")

@onready var tier1Mat := preload("res://DevAssets/Materials/PalletOne/DM_Grey.tres")
@onready var tier2Mat := preload("res://DevAssets/Materials/PalletOne/DM_Green.tres")
@onready var tier3Mat := preload("res://DevAssets/Materials/PalletOne/DM_Violet.tres")

# Basic vars

var blinkFlip: bool = true
var blinkTimer: float = 0.0
var blinkInterval: float = 0.5  # seconds per blink

func _ready() -> void:
	super._ready()
	type = slotType
	
	setIndicators()

func _process(delta: float) -> void:
	if placed:
		blinkTimer += delta
		if blinkTimer >= blinkInterval:
			blinkTimer = fmod(blinkTimer, blinkInterval)
			blinkFlip = !blinkFlip
	else:
		blinkFlip = true
	
	if blinkFlip:
		blinkIndicatorMesh.material_override = blinkOffMat
	else:
		blinkIndicatorMesh.material_override = blinkOnMat

func setIndicators():
	match slotType:
		"processingRack":
			slotIndicatorMesh.material_override = processingMat
		"uploadingRack":
			slotIndicatorMesh.material_override = uploadingMat
		"wipingRack":
			slotIndicatorMesh.material_override = wipingMat
		"automationRack":
			slotIndicatorMesh.material_override = automationMat
	
	match tier:
		"tier1":
			tierIndicatorMesh.material_override = tier1Mat
		"tier2":
			tierIndicatorMesh.material_override = tier2Mat
		"tier3":
			tierIndicatorMesh.material_override = tier3Mat
