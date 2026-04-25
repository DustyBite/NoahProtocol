extends RigidBody3D
class_name InteractableBase

@onready var mesh := $MeshInstance3D

var baseMat : Material
var hoverMat : Material

func _ready() -> void:
	
	baseMat = mesh.get_surface_override_material(0)
	hoverMat = mesh.get_active_material(0).duplicate()
	hoverMat.stencil_mode = 1

@rpc("any_peer", "call_local", "reliable")
func moveTo(targetPos, delta):
	position = position.lerp(targetPos, 10 * delta)

@rpc("any_peer", "call_local", "reliable")
func release(velocity):
	linear_velocity = velocity

func can_drag() -> bool:
	return true

func hover(value):
	if value:
		mesh.material_override = hoverMat
	else:
		mesh.material_override = baseMat
