extends InteractableStatic

# Export vars

@export var gameLabel: String
@export var gameScene: PackedScene

# Onready var

@onready var machineLabel = $machineLabelSubviewport/Control/Panel/Label

# Basic var

var gameController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	if gameLabel != "":
		machineLabel.text = gameLabel
	
	if gameScene != null:
		gameController = gameScene.instantiate()
		$gameSubviewport.add_child(gameController)

func interact(body):
	if body.has_method("enterTerminal") and gameController != null:
		body.enterTerminal(gameController, true)
