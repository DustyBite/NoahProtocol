extends Node3D
class_name InteractableStatic

@export var hoverMesh: Node

@export var interactButton: String = ""

var baseMat : Material
var hoverMat : Material

var baseMatArray : Array[Material]
var hoverMatArray : Array[Material]

func _ready() -> void:
	add_to_group("interactable")
	
	updateHoverMat()


func updateHoverMat():
	baseMatArray.clear()
	hoverMatArray.clear()
	
	if hoverMesh == null:
		return
	
	if hoverMesh is MeshInstance3D:
		baseMat = hoverMesh.get_surface_override_material(0)
		hoverMat = hoverMesh.get_active_material(0).duplicate()
		hoverMat.stencil_mode = 1
		hoverMat.stencil_color = Globals.hoverColor
	else:
		for mesh in hoverMesh.get_children():
			baseMatArray.append(mesh.get_surface_override_material(0))
			var dupMat = mesh.get_active_material(0).duplicate()
			dupMat.stencil_mode = 1
			dupMat.stencil_color = Globals.hoverColor
			hoverMatArray.append(dupMat)

func hover(value):
	if hoverMesh is MeshInstance3D:
		hoverMesh.material_override = hoverMat if value else baseMat
	else:
		var children = hoverMesh.get_children()
		for i in range(children.size()):
			children[i].material_override = hoverMatArray[i] if value else baseMatArray[i]
