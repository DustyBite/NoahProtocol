extends RigidBody3D
class_name InteractableDynamic

@export var mesh : MeshInstance3D
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

@rpc("any_peer", "call_local")
func moveTo(targetPosition: Vector3, delta: float, camPosition: Vector3) -> void:
	var direction = (targetPosition - global_position)
	linear_velocity = direction * 10  # tune drag_speed, e.g. 10.0
	freeze = false  # make sure freeze is off while moving
	
	if fixRot:
		var lookDir = (camPosition - global_position).normalized()
		var targetBasis = Basis.looking_at(lookDir, Vector3.UP)
		quaternion = quaternion.slerp(targetBasis.get_rotation_quaternion(), delta * 5)

@rpc("any_peer", "call_local", "reliable")
func release(velocity):
	linear_velocity = velocity
