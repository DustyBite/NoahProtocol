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
var interItem


# Drag vars
var draggedItem = null
var chargedThrow: bool = false
var lastDragPosition = Vector3.ZERO
var dragVelocity = Vector3.ZERO
@export var dragStrength = 10.0  # How fast objects follow
@export var dragOffset: float = 1.5   # Distance from camera
@export var throwMultiplier = 5.0

# UI Items
@onready var pauseUi := $playerUi/pauseUi
@onready var mainUi := $playerUi/mainUi
@onready var uiLabel := $playerUi/mainUi/Label

@onready var hStatUI := $playerUi/mainUi/hungerBar
@onready var eStatUI := $playerUi/mainUi/exhaustionBar
@onready var sStatUI := $playerUi/mainUi/sanityBar


# Player Stats
var hunger: float = 100.0
var hungerMod: float = 0.0

var exhaustion: float = 100.0
var exhaustionMod: float = 0.0
var maxExhaRegen: float = 50.0

var sanity: float = 100.0
var sanityMod: float = 0.0

var drainRate: float = 0.5


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

func _process(delta: float) -> void:
	if not multiplayer or not multiplayer.multiplayer_peer:
		return
	
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("pause"):
		togglePause()
	
	if isPaused:
		return
	
	checkRayCol()
	
	hunger = hunger - delta * drainRate
	exhaustion = exhaustion - delta * (drainRate + hungerMod)
	sanity = sanity - delta * (drainRate + (hungerMod / 2) + exhaustionMod)
	
	updateStats()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("leftClick"):
		if interItem != null and interItem.has_method("receiveRayInput"):
			interItem.receiveRayInput(intRay.get_collision_point(), true)
	
	if event.is_action_pressed("interact"):
		if interItem != null and interItem.has_method("interact"):
				interItem.interact(self)



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
	
	if Input.is_action_just_pressed("leftClick"):
		grabObject()
	elif Input.is_action_just_released("leftClick"):
		releaseObject()

	if Input.is_action_just_pressed("rightClick"):
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
		var forward = -global_transform.basis.z
		var right = -global_transform.basis.x
		var relative_direction = (right * input_dir.x + forward * input_dir.y).normalized()
		direction = lerp(direction, relative_direction, delta * lerpSpeed)

		if direction != Vector3.ZERO:
			velocity.x = direction.x * (currentSpeed - (hungerMod * 4))
			velocity.z = direction.z * (currentSpeed - (hungerMod * 4))
		else:
			velocity.x = move_toward(velocity.x, 0, (currentSpeed - (hungerMod * 4)))
			velocity.z = move_toward(velocity.z, 0, (currentSpeed - (hungerMod * 4)))
		
		move_and_slide()
		
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

			if collider is RigidBody3D:
				var collision_point = collision.get_position()
				var push_force = 10.0
			
				var push_direction = -collision.get_normal()
				collider.apply_force(push_direction * push_force * currentSpeed, collision_point - collider.global_position)

func updateStats():
	hStatUI.value = hunger
	eStatUI.value = exhaustion
	sStatUI.value = sanity
	
	if hunger < 50:
		hungerMod = .5
	else:
		hungerMod = 0.0
	
	if exhaustion < 50:
		exhaustionMod = .5
	else:
		exhaustionMod = 0.0

#var exhaustion: float = 100.0
#var exhaustionMod: float = 0.0
#var maxExhaRegen: float = 50.0

func consume(type):
	match type:
		"eDrink":
			if exhaustion + maxExhaRegen > 100:
				exhaustion = 100
			else:
				exhaustion = exhaustion + maxExhaRegen
			maxExhaRegen = maxExhaRegen/2
		"FOOD":
			pass

func chargeThrow(value):
	chargedThrow = value
	if value:
		dragOffset = 1
	else:
		dragOffset = 1.5

func grabObject():
	if intRay.is_colliding():
		var body = intRay.get_collider()
		if "canDrag" in body and body.canDrag:
			draggedItem = body
			lastDragPosition = draggedItem.global_position
			if draggedItem is RigidBody3D:
				draggedItem.lock_rotation = false
				draggedItem.freeze = true
				intRay.add_exception(draggedItem)
				draggedItem.onGrab()

func releaseObject():
	dragOffset = 1.5
	if draggedItem:
		# Apply throw velocity
		if draggedItem is RigidBody3D:
			draggedItem.freeze = false
			var relVelo = dragVelocity
			if chargedThrow and "chargeThrow" in draggedItem and draggedItem.chargeThrow:
				var throwDirection = -camera.global_transform.basis.z
				relVelo = throwDirection * throwMultiplier
			
			draggedItem.release.rpc(relVelo)
			draggedItem.onRelease()
			intRay.remove_exception(draggedItem)
		
		draggedItem = null
		dragVelocity = Vector3.ZERO

func updateDraggedItem(delta):
	#print(camera, " | ", dragOffset)
	var targetPosition = getDragTargetPosition()
	draggedItem.moveTo.rpc(targetPosition, delta, camera.global_position)
	if chargedThrow:
		draggedItem.resetRotation(true)
	else:
		draggedItem.resetRotation(false)

func getDragTargetPosition() -> Vector3:
	if camera == null:
		return global_position
	if intRay.is_colliding():
		return intRay.get_collision_point()
	else:
		return camera.global_position + (-camera.global_transform.basis.z * dragOffset)

func getInteractable(collider: Node) -> Node:
	var node = collider
	while node != null:
		if node.is_in_group("interactable"):
			return node
		node = node.get_parent()
	return null

func checkRayCol():
	var newItem
	if intRay.is_colliding():
		newItem = getInteractable(intRay.get_collider())
		
		if newItem != interItem:
			# Turn off the OLD item before switching
			if interItem != null and interItem.has_method("hover"):
				interItem.hover(false)
			interItem = newItem
		
		if "interactButton" in newItem:
			uiLabel.text = newItem.interactButton
		
		if interItem.has_method("hover"):
			interItem.hover(true)
	else:
		if interItem != null:
			if interItem.has_method("hover"):
				interItem.hover(false)
		interItem = null
		uiLabel.text = ""

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
		mainUi.visible = true
		if worldRoot != null:
			if Globals.singleplayerMode:
				get_tree().paused = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		isPaused = true
		pauseUi.visible = true
		mainUi.visible = false
		if worldRoot != null:
			if Globals.singleplayerMode:
				get_tree().paused = true
