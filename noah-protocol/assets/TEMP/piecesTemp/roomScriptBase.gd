extends Node

@export var mLight: Node3D
@export var eLight: Node3D

var lightOn: bool = true

func _process(_delta: float) -> void:
	if Globals.powerOn:
		eLight.visible = false
	else:
		eLight.visible = true
	
	if lightOn and Globals.powerOn:
		mLight.visible = true
	else:
		mLight.visible = false
