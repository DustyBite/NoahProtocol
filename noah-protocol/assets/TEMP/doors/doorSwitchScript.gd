extends Node

@export var doorMain: Node

@onready var mesh := $doorSwitchBase

var lockStatus: bool = true

var mat

func _ready() -> void:
	mat = mesh.get_active_material(0).duplicate()
	mesh.set_surface_override_material(0, mat)

func _process(_delta: float) -> void:
	if doorMain.locked != lockStatus:
		print(lockStatus)
		lockStatus = doorMain.locked
		updateScanner()

func updateScanner():
	var color = Color(0,0.5,0)
	if lockStatus:
		color = Color(0.5,0,0)
	
	mat.set_shader_parameter("scannerColor", color)
