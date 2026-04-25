extends CharacterBody3D

# Player nodes
@onready var head := $head
@onready var camera := $head/firstPersonCamera
@onready var standingCollisionShape := $standingCollisionShape
@onready var crouchingCollisionShape := $crouchingCollisionShape
@onready var playerHeightRC := $crouchRC
@onready var jumpHeightRC := $jumpRC
@onready var flashlight := $head/flashlight
var currentVehicle: VehicleBody3D = null

var masterBusIndex = AudioServer.get_bus_index("Master")

var activeTerminal = null

#misc
var enviorLocal = 0
var worldRoot: Node3D
var playerCash = 100
var driving = false
var gasAmount = 0
var inTerminal = false
var inPauseMenu = false

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
var flashlightToggle = 0
var buildM = 0

# Seating state
var isPaused: bool = false

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var intRay = $head/interactionRay
var interItem: RigidBody3D


# Drag vars
var draggedItem = null
var chargedThrow: bool = false
var lastDragPosition = Vector3.ZERO
var dragVelocity = Vector3.ZERO
@export var dragStrength = 10.0  # How fast objects follow
@export var dragOffset = 1.5   # Distance from camera
@export var throwMultiplier = 5.0

# UI Items
@onready var pauseUi := $pauseUi

func _ready():
	pauseUi.player = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_post_ready")

func _post_ready():
	print("Player:", name, " Authority:", get_multiplayer_authority())

	#setup_visibility_layers()

	if is_multiplayer_authority():
		camera.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("✓ Local player")
	else:
		# Remote players never keep cameras
		camera.queue_free()
		print("✗ Remote player")

func _unhandled_input(event):
	if not multiplayer or not multiplayer.multiplayer_peer:
		return
	
	if not is_multiplayer_authority():
		return
	
	if isPaused:
		return
	
	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSens))
		head.rotate_x(deg_to_rad(event.relative.y * mouseSens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	# Other gameplay inputs
	if Input.is_action_just_pressed("flashlight"):
		toggleFlashlight()

func _process(_delta: float) -> void:
	if not multiplayer or not multiplayer.multiplayer_peer:
		return
	
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("pause"):
		togglePause()
	
	if isPaused:
		return
	
	checkRayCol()


func _physics_process(delta: float) -> void:
	if not multiplayer or not multiplayer.multiplayer_peer:
		return
		
	if not is_multiplayer_authority():
		# Prevent drift on remote players (but still update dragged items!)
		if not draggedItem:
			velocity = Vector3.ZERO
			return
	
	if get_tree().paused:
		return
	
	# ALWAYS update dragged items, regardless of player authority
	if draggedItem:
		updateDraggedItem(delta)
	
	if Input.is_action_pressed("leftClick"):
		print("Dave")
		grabObject()
	else:
		releaseObject()
	
	if Input.is_action_pressed("rightClick"):
		chargeThrow(true)
	elif Input.is_action_just_released("rightClick"):
		chargeThrow(false)
	
	# Only do player movement if we have authority
	if is_multiplayer_authority():
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
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

			if collider is RigidBody3D:
				var collision_point = collision.get_position()
				var push_force = 10.0
			
				var push_direction = -collision.get_normal()
				collider.apply_force(push_direction * push_force * currentSpeed, collision_point - collider.global_position)

func chargeThrow(value):
	chargedThrow = value
	if value:
		dragOffset = 1
	else:
		dragOffset = 1.5

func grabObject():
	if intRay.is_colliding():
		var body = intRay.get_collider()
		if body.has_method("can_drag") and body.can_drag():
			draggedItem = body
			lastDragPosition = draggedItem.global_position
			
			# Disable gravity while dragging
			if draggedItem is RigidBody3D:
				draggedItem.lock_rotation = false
				draggedItem.freeze = true
				# Exclude the dragged object from raycast detection
				intRay.add_exception(draggedItem)

func releaseObject():
	dragOffset = 1.5
	if draggedItem:
		# Apply throw velocity
		if draggedItem is RigidBody3D:
			draggedItem.freeze = false
			var relVelo = dragVelocity
			if chargedThrow:
				var throwDirection = -camera.global_transform.basis.z
				relVelo = throwDirection * throwMultiplier
			
			draggedItem.release.rpc(relVelo)
			
			# Re-enable raycast collision with this object
			intRay.remove_exception(draggedItem)
		
		draggedItem = null
		dragVelocity = Vector3.ZERO

func updateDraggedItem(delta):
	var targetPosition = getDragTargetPosition()
	draggedItem.moveTo.rpc(targetPosition, delta)

func getDragTargetPosition() -> Vector3:
	if intRay.is_colliding():
		return intRay.get_collision_point()
	else:
		return camera.global_position + (-camera.global_transform.basis.z * dragOffset)

func checkRayCol():
	var newItem = intRay.get_collider() if intRay.is_colliding() else null
	
	if newItem != interItem:
		for item in [interItem, newItem]:
			if item and item.has_method("hover"):
				item.hover(item == newItem)
		interItem = newItem

func toggleFlashlight():
	if flashlightToggle == 0:
		flashlight.light_energy = 1
		flashlightToggle = 1
	else:
		flashlight.light_energy = 0
		flashlightToggle = 0

func togglePause():
	if isPaused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		isPaused = false
		pauseUi.visible = false
		if worldRoot != null:
			if Globals.singleplayerMode:
				get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		isPaused = true
		pauseUi.visible = true
		if worldRoot != null:
			if Globals.singleplayerMode:
				get_tree().paused = true
