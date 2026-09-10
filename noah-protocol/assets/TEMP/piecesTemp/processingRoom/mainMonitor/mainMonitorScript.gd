extends Node

@onready var totalTally := $SubViewport/Control/Panel/tpgTally
@onready var processTally := $SubViewport/Control/Panel/tcpTally

func _process(_delta: float) -> void:
	totalTally.text = str(Globals.pointTotal)
	processTally.text = str(Globals.cardsProcessed)
