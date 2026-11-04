extends Node3D
class_name InteractableStatic

# Export vars

@export var hoverMeshArray: Array[Node]

@export var interactButton: String = ""

# Onready vars

# Basic Vars


var baseMaterial: Array[Material]

func _ready() -> void:
	add_to_group("interactable")
	
	baseMaterial.clear()
	
	for mesh in hoverMeshArray:
		var mat = mesh.get_active_material(0).duplicate()
		if mat.next_pass != null:
			mat.next_pass = mat.next_pass.duplicate()
		mesh.set_surface_override_material(0, mat)
		baseMaterial.append(mat)

func hover(value):
	if baseMaterial.is_empty():
		return
	
	for mat in baseMaterial:
		var outlineMat = mat.next_pass
		if outlineMat == null:
			continue
		
		outlineMat.set_shader_parameter("outlineToggle", value)
		if value:
			outlineMat.set_shader_parameter("outlineColor", Globals.hoverColor)
