extends RigidBody3D
class_name botBase

# Misc vars
var currentTask: String = "idle"

# Movement vars
@export_group("Movement")
@export var angelWindow: float = .5
@export var rotationSpeed: float = 1.0
@export var moveSpeed: float = 3.0
@export var locTolerance: float = 0.05
@export var pathManager: Node3D
var pathNodes: Array
var currentPathPos: int = 0
var currentNode: Node
var previousNode: Node
var location: String = ""
var rotateToFace: bool = false

# Battery/Charger vars
@export_group("Battery & Charger")
@export var chargerObj: Node

# Task vars
var targetObj: Node
var targetLocation: Node


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	checkTask(delta)


func _physics_process(delta: float) -> void:
	if location == "movement":
		moveTo(delta)


# --- Tasks ---

func checkTask(delta) -> void:
	if currentTask == "idle":
		idleTask()
	else:
		runTask(delta)


# Override in child scripts to handle their own task names
func runTask(_delta) -> void:
	pass


func idleTask() -> void:
	if isAtTarget(chargerObj):
		if location == "charger":
			return
		location = "charger"
		clearPath()
		return
	startPathTo(chargerObj)


func assignTask(object, destination, label) -> void:
	targetObj = object
	targetLocation = destination
	currentTask = label

	pathManager.clearPath(pathNodes)
	pathNodes.clear()
	currentPathPos = 0
	currentNode = null
	previousNode = null


# --- Helpers ---

func isAtTarget(target: Node, tolerance: float = -1.0) -> bool:
	if tolerance < 0:
		tolerance = locTolerance
	var a = global_position
	var b = target.global_position
	a.y = 0
	b.y = 0
	return a.distance_to(b) < tolerance


func startPathTo(target: Node) -> void:
	location = "movement"
	if !pathNodes.is_empty():
		return
	var markA = pathManager.findClosest(self)
	var markB = pathManager.findClosest(target)
	pathNodes = pathManager.getPath(markA, markB)
	pathNodes.append(target)
	currentNode = pathNodes[0]
	if "indicator" in currentNode:
		currentNode.indicator = "target"


# --- Movement ---

func moveTo(delta) -> void:
	if pathNodes.is_empty():
		return

	var botPos = global_position
	var curNodePos = currentNode.global_position
	curNodePos.y = botPos.y

	if rotateToFace:
		var direction = curNodePos - botPos
		var angleRad = atan2(direction.x, direction.z)

		var angleTolerance = .005
		var currentRad = deg_to_rad(rotation_degrees.y)

		if abs(angle_difference(angleRad, currentRad)) > angleTolerance:
			rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
			return
		else:
			rotateToFace = false
			rotation_degrees.y = rad_to_deg(angleRad)

	if botPos.distance_to(curNodePos) < locTolerance:
		getNextNode()
	else:
		global_position = global_position.move_toward(curNodePos, moveSpeed * delta)


func clearPath() -> void:
	pathManager.clearPath(pathNodes)
	pathNodes.clear()
	currentPathPos = 0
	rotateToFace = true
	currentNode = null
	previousNode = null


func getNextNode() -> void:
	currentPathPos += 1
	if currentPathPos < pathNodes.size():
		if previousNode != null and "indicator" in previousNode:
			previousNode.indicator = "plain"
		previousNode = currentNode
		currentNode = pathNodes[currentPathPos]
		rotateToFace = true
		if "indicator" in currentNode:
			currentNode.indicator = "target"
