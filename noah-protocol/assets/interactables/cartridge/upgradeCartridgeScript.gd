extends InteractableDynamic

# Onready vas

@onready var statusLight: MeshInstance3D = $statusLight
@onready var indicLight: MeshInstance3D = $indicatorLight
@onready var upgradeMarker: MeshInstance3D = $upgradeMesh

#Colors
@onready var greyMat := preload("res://DevAssets/Materials/PalletOne/DM_Grey.tres")
@onready var greenMat := preload("res://DevAssets/Materials/PalletOne/DM_Green.tres")
@onready var redMat := preload("res://DevAssets/Materials/PalletOne/DM_BrightRed.tres")
@onready var orangeMat := preload("res://DevAssets/Materials/PalletOne/DM_Orange.tres")
@onready var blueMat := preload("res://DevAssets/Materials/PalletOne/DM_Blue.tres")

@onready var processUpgradeMat := preload("res://DevAssets/Materials/OldPallet/DTPO_Mat_MutedBlue.tres")
@onready var uploadUpgradeMat := preload("res://DevAssets/Materials/OldPallet/DTPO_Mat_SageGreen.tres")
@onready var wipeUpgradeMat := preload("res://DevAssets/Materials/OldPallet/DTPO_Mat_DustyRed.tres")

# Export var

@export var speedModifer: int = 1

# Basic var

var blinkFlip: bool = true
var blinkTimer: float = 0.0
var blinkInterval: float = 0.5  # seconds per blink

func _ready() -> void:
	super._ready()
	
	blinkTimer = randf() * blinkInterval
	
	setUpgradeMat()

func _process(delta: float) -> void:
	blinkTimer += delta
	if blinkTimer >= blinkInterval:
		blinkTimer = fmod(blinkTimer, blinkInterval)
		blinkIndicLight()

func blinkIndicLight():
	blinkFlip = !blinkFlip
	
	if blinkFlip:
		indicLight.material_override = greyMat
	else:
		indicLight.material_override = greenMat

func setUpgradeMat():
	match type:
		"processUpgrade":
			upgradeMarker.material_override = processUpgradeMat
		"uploadUpgrade":
			upgradeMarker.material_override = uploadUpgradeMat
		"wipeUpgrade":
			upgradeMarker.material_override = wipeUpgradeMat
