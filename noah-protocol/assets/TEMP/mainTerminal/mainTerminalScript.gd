extends InteractableStatic

# Export var

@export var deliverySpawner: Node


# Onready var

@onready var screenController = $SubViewport/mainTerminalScreen
@onready var terminalCam = $Camera3D
@onready var emailIndicator = $newEmailIndicator

@onready var greyMat:= preload("res://DevAssets/Materials/PalletOne/DM_Grey.tres")
@onready var yellowMat:= preload("res://DevAssets/Materials/PalletOne/DM_Yellow.tres")

# Basic var

var blinkFlip: bool = true
var blinkTimer: float = 0.0
var blinkInterval: float = 0.5  # seconds per blink

func _ready() -> void:
	super._ready()
	
	blinkTimer = randf() * blinkInterval

func _process(delta: float) -> void:
	if Globals.hasUnreadEmail():
		blinkTimer += delta
		if blinkTimer >= blinkInterval:
			blinkTimer = fmod(blinkTimer, blinkInterval)
			blinkIndicLight()
	else:
		blinkFlip = false
		blinkIndicLight()

func blinkIndicLight():
	blinkFlip = !blinkFlip
	
	if blinkFlip:
		emailIndicator.material_override = greyMat
	else:
		emailIndicator.material_override = yellowMat

func interact(body):
	if body.has_method("enterTerminal"):
		body.enterTerminal(screenController, terminalCam, false)

func spawnUpgrade(cardScene, type, modifier):
	var card = cardScene.instantiate()
	var worldRoot = get_tree().current_scene
	var spawnPos = deliverySpawner.global_position
	spawnPos.y += 1
	
	card.type = type
	card.speedModifer = modifier
	
	worldRoot.add_child(card)
	
	card.global_position = spawnPos
