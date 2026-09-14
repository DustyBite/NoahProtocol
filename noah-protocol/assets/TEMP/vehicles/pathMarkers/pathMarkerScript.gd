extends Marker3D

@export var neighbors: Array[Marker3D]

@onready var ghostMesh = $ghostMarker

var plainMat = preload("res://DevAssets/Materials/GhostPallet/DMCyanGhost.tres")
var activeMat = preload("res://DevAssets/Materials/GhostPallet/DMYellowGhost.tres")
var targetedMat = preload("res://DevAssets/Materials/GhostPallet/DMRoseGhost.tres")

var indicator: String = "plain"

func _process(_delta: float) -> void:
	if Globals.devMode:
		$ghostMarker.visible = true
	else:
		$ghostMarker.visible = false
		return
	
	checkIndicator()

func checkIndicator():
	match indicator:
		"plain":
			ghostMesh.material_override = plainMat
		"target":
			ghostMesh.material_override = targetedMat
		"active":
			ghostMesh.material_override = activeMat
