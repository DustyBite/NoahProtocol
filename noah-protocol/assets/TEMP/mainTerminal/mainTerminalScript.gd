extends InteractableStatic

# Export var

@export var deliverySpawner: Node

# Onready var

@onready var screenController = $SubViewport/mainTerminalScreen

func interact(body):
	if body.has_method("enterTerminal"):
		body.enterTerminal(screenController, false)

func spawnUpgrade(cardScene, type, modifier):
	var card = cardScene.instantiate()
	var worldRoot = get_tree().current_scene
	var spawnPos = deliverySpawner.global_position
	spawnPos.y += 1
	
	card.type = type
	card.speedModifer = modifier
	
	worldRoot.add_child(card)
	
	card.global_position = spawnPos
