extends InteractableDynamic

@onready var statusLight: MeshInstance3D = $statusLight
@onready var indicLight: MeshInstance3D = $indicatorLight

#Colors
@onready var greyMat := preload("res://DevAssets/Materials/PalletOne/DM_Grey.tres")
@onready var greenMat := preload("res://DevAssets/Materials/PalletOne/DM_Green.tres")
@onready var redMat := preload("res://DevAssets/Materials/PalletOne/DM_BrightRed.tres")
@onready var orangeMat := preload("res://DevAssets/Materials/PalletOne/DM_Orange.tres")
@onready var blueMat := preload("res://DevAssets/Materials/PalletOne/DM_Blue.tres")

var status: String = "upload"

var blinkFlip: bool = true
var blinkTimer: float = 0.0
var blinkInterval: float = 0.5  # seconds per blink

var processProgress: float = 0
var wipeProgress: float = 0

func _ready() -> void:
	super._ready()
	
	TEMPrandStatus()
	
	blinkTimer = randf() * blinkInterval

func _process(delta: float) -> void:
	blinkTimer += delta
	if blinkTimer >= blinkInterval:
		blinkTimer = fmod(blinkTimer, blinkInterval)
		blinkIndicLight()
	
	updateStatus()

func getPoints() -> int:
	match status:
		"loaded": return -20
		"processing": return 0
		"clear": return 15
		"corrupted": return -5
	return 0

func updateStatus():
	match status:
		"loaded":
			statusLight.material_override = greenMat
		"processing":
			statusLight.material_override = orangeMat
		"clear":
			statusLight.material_override = blueMat
		"corrupted":
			statusLight.material_override = redMat

func blinkIndicLight():
	blinkFlip = !blinkFlip
	
	if blinkFlip:
		indicLight.material_override = greyMat
	else:
		indicLight.material_override = greenMat

func TEMPrandStatus():
	if randf() < 0.05:
		status = "corrupted"
	else:
		status = "loaded"
