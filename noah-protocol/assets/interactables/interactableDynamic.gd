extends RigidBody3D
class_name InteractableDynamic

# Export vars

@export var hoverMeshArray: Array[Node]
@export var canDrag: bool = true

@export var chargeThrow: bool = true
@export var fixableRot: bool = false
@export var removeCol: bool = true
@export var placable: bool = true
@export var type: String

@export var interactButton: String = ""

# Onready vars

# Basic Vars

var placed: bool = false

var fixRot: = false

var slot

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
