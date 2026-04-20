extends CharacterBody3D

# Player nodes
@onready var head := $head
@onready var playerCam := $head/firstPersonCamera
@onready var standingCollisionShape := $standingCollisionShape
@onready var crouchingCollisionShape := $crouchingCollisionShape
@onready var playerHeightRC := $crouchRC
@onready var jumpHeightRC := $jumpRC
@onready var firstPersonCamera := $head/firstPersonCamera
@onready var flashlight := $head/flashlight
var currentVehicle: VehicleBody3D = null

var masterBusIndex = AudioServer.get_bus_index("Master")

var activeTerminal = null

#misc
var enviorLocal = 0
var playerCash = 100
var driving = false
var gasAmount = 0
var inTerminal = false
var inPauseMenu = false

#packages
@onready var boxPos := $boxPos
@onready var boxDrop := $boxDrop
var carryMax = 10
var carrying = 0
var carryIndex = 0
var itemArray: Array = [null, null, null, null, null, null, null, null]
#var item: Node3D
var carryType = "Null"

# World Nodes
var main_scene = null

# Speed Variables
var currentSpeed = 5.0
const walkingSpeed = 4.0
const sprintingSpeed = 8.0
const crouchingSpeed = 2.0

# movement Vars
var crouchingDepth = -0.5
const jumpVelocity = 4.5
var lerpSpeed = 10.0

# Input Variables
var direction = Vector3.ZERO
const mouseSens = 0.25
var camera = 1
var flashlightToggle = 0
var buildM = 0

# Seating state
var isSeated = false

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_scene = get_tree().root.get_node("root")

func _input(event):

	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSens))
		head.rotate_x(deg_to_rad(event.relative.y * mouseSens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

	# Other gameplay inputs
	#if Input.is_action_just_pressed("changeCamera"):
		#changeCamera()
	if Input.is_action_just_pressed("flashlight"):
		toggleFlashlight()

func _physics_process(delta: float) -> void:
	# Ignore all other inputs while paused
	if get_tree().paused or inTerminal:
		return
	
	# Crouching
	if Input.is_action_pressed("crouch"):
		currentSpeed = crouchingSpeed
		head.position.y = lerp(head.position.y, 1.4 + crouchingDepth, delta * lerpSpeed)
		standingCollisionShape.disabled = true
		crouchingCollisionShape.disabled = false
		
	elif !playerHeightRC.is_colliding():
		head.position.y = lerp(head.position.y, 1.4, delta * lerpSpeed)
		standingCollisionShape.disabled = false
		crouchingCollisionShape.disabled = true
		
		if Input.is_action_pressed("sprint"):
			currentSpeed = sprintingSpeed
		else:
			currentSpeed = walkingSpeed
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !jumpHeightRC.is_colliding():
		velocity.y = jumpVelocity

	# Movement
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var forward = -head.global_transform.basis.z
	var right = -head.global_transform.basis.x
	var relative_direction = (right * input_dir.x + forward * input_dir.y).normalized()
	direction = lerp(direction, relative_direction, delta * lerpSpeed)

	if direction != Vector3.ZERO:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()

func toggleFlashlight():
	if flashlightToggle == 0:
		flashlight.light_energy = 1
		flashlightToggle = 1
	else:
		flashlight.light_energy = 0
		flashlightToggle = 0
