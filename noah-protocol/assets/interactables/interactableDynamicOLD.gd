extends RigidBody3D
class_name InteractableDynamicOld

@export var hoverMesh: Node
@export var canDrag: bool = true

@export var chargeThrow: bool = true
@export var fixableRot: bool = false
@export var removeCol: bool = true
@export var placable: bool = true
@export var type: String

@export var interactButton: String = ""

var placed: bool = false

var fixRot: = false

var slot

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

	if hoverMesh is MeshInstance3D:
		baseMat = hoverMesh.get_surface_override_material(0)
		hoverMat = hoverMesh.get_active_material(0).duplicate()
		hoverMat.stencil_mode = 1
	else:
		for mesh in hoverMesh.get_children():
			baseMatArray.append(mesh.get_surface_override_material(0))
			var dupMat = mesh.get_active_material(0).duplicate()
			dupMat.stencil_mode = 1
			hoverMatArray.append(dupMat)

func hover(value):
	if hoverMesh is MeshInstance3D:
		hoverMesh.material_override = hoverMat if value else baseMat
	else:
		var children = hoverMesh.get_children()
		for i in range(children.size()):
			children[i].material_override = hoverMatArray[i] if value else baseMatArray[i]

func place() -> void:
	freeze = true
	lock_rotation = true
	if removeCol:
		set_collision_layer_value(2, false)
		set_collision_layer_value(1, false)
	placed = true

func unplace() -> void:
	freeze = false
	lock_rotation = false
	if removeCol:
		set_collision_layer_value(2, true)
		set_collision_layer_value(1, true)
	placed = false

func onGrab() -> void:
	set_collision_layer_value(2, false)
	if slot != null:
		slot.clearSlot()
		slot = null


func onRelease() -> void:
	set_collision_layer_value(2, true)
	
	if slot != null:
		slot.slotItem(self)

func resetRotation(value):
	fixRot = value

func moveTo(targetPosition: Vector3, delta: float, camPosition: Vector3) -> void:
	var direction = (targetPosition - global_position)
	linear_velocity = direction * 10  # tune drag_speed, e.g. 10.0
	freeze = false  # make sure freeze is off while moving
	
	if fixRot:
		var lookDir = (camPosition - global_position).normalized()
		var targetBasis = Basis.looking_at(lookDir, Vector3.UP)
		quaternion = quaternion.slerp(targetBasis.get_rotation_quaternion(), delta * 5)

func release(velocity):
	linear_velocity = velocity
