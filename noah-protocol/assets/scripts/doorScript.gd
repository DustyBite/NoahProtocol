extends RigidBody3D

@onready var minAngle: float = 0.0
@onready var maxAngle: float = 0.0

@onready var detectionArea: Area3D = $collisionArea
@onready var hingeJoint: HingeJoint3D = $HingeJoint3D

@export var rotationOffset: float = 0.0
@export var closeDelay: float = 1.0  # Seconds before auto-close
var timeSinceStopped: float = 0.0

var isContacting: bool = false

@export var Debug: bool = false

func _ready():
	if hingeJoint:
		minAngle = hingeJoint.get_param(HingeJoint3D.PARAM_LIMIT_UPPER)
		minAngle = hingeJoint.get_param(HingeJoint3D.PARAM_LIMIT_LOWER)
	
	if detectionArea:
		detectionArea.body_entered.connect(_on_body_entered)
		detectionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D):
	if body is CharacterBody3D:
		isContacting = true

func _on_body_exited(body: Node3D):
	if body is CharacterBody3D:
		isContacting = false

func _physics_process(delta: float) -> void:
	var currentAngle = rotation_degrees.y + rotationOffset
	currentAngle = deg_to_rad(currentAngle)
	var isOpen = abs(currentAngle) > 0.01
	
	if Debug:
		print(currentAngle)
		print(isOpen)
	
	# Track time
	if isOpen and not isContacting:
		timeSinceStopped += delta
	else:
		timeSinceStopped = 0.0
	
	# Auto-close after delay
	if timeSinceStopped >= closeDelay and isOpen:
		var targetSpeed = -currentAngle * 2.5
		
		hingeJoint.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, true)
		hingeJoint.set_param(HingeJoint3D.PARAM_MOTOR_TARGET_VELOCITY, targetSpeed)
	else:
		# Turn off motor when closed or being touched
		hingeJoint.set_flag(HingeJoint3D.FLAG_ENABLE_MOTOR, false)
		
		# Snap to closed if very close
		if abs(currentAngle) < 0.01:
			rotation_degrees.y = -rotationOffset
