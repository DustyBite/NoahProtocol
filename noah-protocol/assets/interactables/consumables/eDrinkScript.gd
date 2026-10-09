extends InteractableDynamicOld

@export var IndicatorMesh : Node

@onready var typeAMat : Material = preload("res://DevAssets/Materials/PalletOne/DM_Green.tres")
@onready var typeBMat : Material = preload("res://DevAssets/Materials/PalletOne/DM_Rose.tres")

@onready var emptyMat : Material = preload("res://DevAssets/Materials/OldPallet/DTPO_Mat_LightGrey.tres")

var full : bool = true
var consumeType = "A"
var consumeValue: int = 4

func _ready() -> void:
	super._ready()
	
	updateConsumeType()

func _process(_delta: float) -> void:
	if !full:
		IndicatorMesh.material_override = emptyMat

func interact(body):
	if full:
		if body.has_method("consume"):
			body.consume("eDrink", consumeValue)
			full = false

func updateConsumeType():
	match consumeType:
		"A":
			IndicatorMesh.material_override = typeAMat
			consumeValue = 4
		"B":
			IndicatorMesh.material_override = typeBMat
			consumeValue = 2
