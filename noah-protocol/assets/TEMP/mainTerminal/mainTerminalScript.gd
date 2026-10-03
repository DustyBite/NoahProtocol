extends InteractableStatic

@onready var screenController = $SubViewport/mainTerminalScreen

func interact(body):
	if body.has_method("enterTerminal"):
		body.enterTerminal(screenController)
