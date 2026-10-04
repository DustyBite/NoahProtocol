extends Node

var singleplayerMode = true
var launchMode: String

var devMode: bool = false

var pointTotal: float = 0
var cardsProcessed: float = 0

var powerOn: bool = true

var type2Consumables: bool = false

var avalibleEmail: int = 0

var unlockArray = [0,0,0,0,0,0,0,0,0]

func _process(_delta: float) -> void:
	if cardsProcessed > 10:
			avalibleEmail = 1
	elif cardsProcessed > 100:
			avalibleEmail = 2
