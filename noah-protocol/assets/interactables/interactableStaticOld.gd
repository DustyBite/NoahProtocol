extends Node3D
class_name InteractableStatic

@export var mesh : MeshInstance3D

@export var interactButton: String = ""

var baseMat : Material
var hoverMat : Material

func _ready() -> void:
	add_to_group("interactable")
	
	baseMat = mesh.get_surface_override_material(0)
	hoverMat = mesh.get_active_material(0).duplicate()
	hoverMat.stencil_mode = 1

func hover(value):
	if value:
		mesh.material_override = hoverMat
	else:
		mesh.material_override = baseMat
