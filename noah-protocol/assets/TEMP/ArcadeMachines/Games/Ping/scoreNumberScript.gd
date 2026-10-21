extends Node2D

@export var redScores: bool = false
@onready var blue: Node2D = $blue
@onready var red: Node2D = $red

var score: int = 0
var currentScore: int = 0

var redNumbers: Array
var blueNumbers: Array

func _ready() -> void:
	redNumbers = red.get_children()
	blueNumbers = blue.get_children()
	
	if redScores:
		blue.visible = false
		red.visible = true

func _process(_delta: float) -> void:
	if currentScore != score:
		blueNumbers[currentScore].visible = false
		redNumbers[currentScore].visible = false
		blueNumbers[score].visible = true
		redNumbers[score].visible = true
		
		currentScore = score
