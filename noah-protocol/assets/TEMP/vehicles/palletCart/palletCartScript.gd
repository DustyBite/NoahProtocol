extends RigidBody3D

# Exports

@export var nodes: Array[Marker3D]
@export var angelWindow: float = .5
@export var rotationSpeed: float = 1.0
@export var moveSpeed: float = 3.0

@export_group("Battery")
@export var batActiveDrainRate : float = 1.0
@export var batPassiveDrainRate : float = 0.5
@export var chargePos : Node

@export_group("TEMP")
@export var palletGrabTEMP: Node

# Plain Var

var turnCart: int = 0
var moving: bool = false
var rotating: bool = false

var currentMarker: Marker3D = null

var arrived : bool = true
var targetCount : int = 0
var currentTarget : Node
var savedTarget : Node

var batLevel : float = 100
var batDead : bool = false
var batNeedCharge: bool = false

var targetPallet: bool = false
var grabbingTarget: bool = false
var palletGrabbed: bool = false

var hasTask: bool = false

func _ready() -> void:
	if palletGrabTEMP != null:
		arrived = false
		currentTarget = palletGrabTEMP
		targetPallet = true

func _process(delta: float) -> void:
	if batDead:
		return
	
	if arrived and !batNeedCharge:
		getNextPoint()
	
	if moving or rotating:
		batLevel -= delta * batActiveDrainRate
	else:
		batLevel -= delta * batPassiveDrainRate
	
	#print(batLevel)
	
	if batLevel < 50:
		batNeedCharge = true
	elif batLevel <= 0:
		batDead = true

func _physics_process(delta: float) -> void:
	if batDead:
		return
	
	if !batNeedCharge:
		botMovement(currentTarget,delta)
	else:
		savedTarget = currentTarget
		chargeBot(chargePos,delta)

func botMovement(target, delta):
	if target == null:
		return
	
	if grabbingTarget:
		grabPallet(delta)
		return
	
	if !moving:
		#print("rotating")
		rotateToTarget(target, delta)
	
	if !rotating:
		#print("moving")
		moveToTarget(target, delta)
	
	if !moving and !rotating and targetPallet:
		grabPallet(delta)
		grabbingTarget = true
	elif !moving and !rotating:
		arrived = true

func moveToTarget(target, delta):
	var locationTolerance = .05
	var targetPos = target.global_position
	targetPos.y = global_position.y
	
	if global_position.distance_to(targetPos) > locationTolerance:
		global_position = global_position.move_toward(targetPos, moveSpeed * delta)
		moving = true
	else:
		moving = false

func rotateToTarget(target, delta):
	var botPos = Vector2(global_position.x, global_position.z)
	var targetPos = Vector2(target.global_position.x, target.global_position.z)
	
	var direction = targetPos - botPos
	var angleRad = atan2(direction.x, direction.y)
	
	var angleTolerance = .05
	var currentRad = deg_to_rad(rotation_degrees.y)
	
	if abs(angleRad - currentRad) > angleTolerance:
		rotating = true
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
	else:
		rotating = false

func getNextPoint():
	if nodes == null:
		return
	
	if !hasTask:
		currentTarget = chargePos
		return
	
	if targetCount < nodes.size():
		currentTarget = nodes[targetCount]
		targetCount += 1
		arrived = false
	else:
		targetCount = 0
		currentTarget = nodes[targetCount]
		arrived = false

func chargeBot(target, delta):
	
	if !moving:
		#print("rotating")
		rotateToTarget(target, delta)
	
	if !rotating:
		#print("moving")
		moveToTarget(target, delta)
	
	if !moving and !rotating:
		batLevel = 100
		arrived = false
		batNeedCharge = false

func grabPallet(delta):
	var currentRad = deg_to_rad(rotation_degrees.y)
	var angleRad = deg_to_rad(palletGrabTEMP.rotation_degrees.y)
	var angleTolerance = .05
	
	if abs(angle_difference(angleRad, currentRad)) > angleTolerance:
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
	elif !palletGrabbed:
		moveSpeed = moveSpeed/2
		rotationSpeed = rotationSpeed/2
		palletGrabbed = true
		grabbingTarget = false
		targetPallet = false
	
		palletGrabTEMP.reparent(self)
		palletGrabTEMP.place()
		palletGrabTEMP.global_transform = global_transform
	
