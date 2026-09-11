extends RigidBody3D

# Exports

@export var nodes: Array[Marker3D]
@export var angelWindow: float = .5
@export var rotationSpeed: float = 0.0
@export var moveSpeed: float = 10.0

@export var TEMPTARGET: RigidBody3D= null

# Plain Var

var turnCart: int = 0
var moving: bool = false
var rotating: bool = false

var currentMarker: Marker3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	
	if !moving:
		moveToTarget(TEMPTARGET,delta)
	
	
	self.transform.basis = self.transform.basis.rotated(Vector3.UP, rotationSpeed)

func moveToTarget(target, delta):
	rotateToTarget(target, delta)
	
	global_transform = lerp(global_transform, target.global_transform, delta/2)

func rotateToTarget(target, delta):
	var botPos = Vector2(global_position.x, global_position.z)
	var targetPos = Vector2(target.global_position.x, target.global_position.z)
	
	var direction = targetPos - botPos
	var angle_rad = atan2(direction.x, direction.y)
	var angleDeg = rad_to_deg(angle_rad)
	
	var crateAngle = self.rotation_degrees.y
	var rotOffset = crateAngle - angleDeg
	
	if rotation_degrees.y != angleDeg:
		rotating = true
		rotation_degrees.y = lerp(rotation_degrees.y, angleDeg, delta)
	else:
		rotating = false
