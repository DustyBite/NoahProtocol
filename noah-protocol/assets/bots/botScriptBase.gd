extends RigidBody3D
class_name botBase

#misc Vars
var currentTask: String = "idle"

#Movement Vars
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

#Battery/Charger Vars
@export_group("Battery & Charger")
@export var chargerObj: Node

var targetObj: Node
var targetLocation: Node
var palletGrabbed: bool = false
var rotateToFace: bool = false

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	checkTask(delta)

func _physics_process(delta: float) -> void:
	
	if location == "movement":
		moveTo(delta)

func checkTask(delta):
	var botPos = global_position
	botPos.y = 0
	
	match currentTask:
		"idle":
			var chargerPos = chargerObj.global_position
			chargerPos.y = 0
			if botPos.distance_to(chargerPos) < locTolerance:
				if location == "charger":
					return
				location = "charger"
				
				clearPath()
				return
			else:
				location = "movement"
				if !pathNodes.is_empty():
					return
				
				var markA = pathManager.findClosest(self)
				var markB = pathManager.findClosest(chargerObj)
				pathNodes = pathManager.getPath(markA, markB)
				pathNodes.append(chargerObj)
				currentNode = pathNodes[0]
				if "indicator" in currentNode:
					currentNode.indicator = "target"
		"grabObject":
			var targetObjPos = targetObj.global_position
			targetObjPos.y = 0
			if botPos.distance_to(targetObjPos) < locTolerance:
				location = "grab"
				grabObject(targetObj, delta)
				if palletGrabbed:
					clearPath()
					currentTask = "moveObject"
				return
			else:
				location = "movement"
				if !pathNodes.is_empty():
					return
				var markA = pathManager.findClosest(self)
				var markB = pathManager.findClosest(targetObj)
				pathNodes = pathManager.getPath(markA, markB)
				pathNodes.append(targetObj)
				currentNode = pathNodes[0]
				if "indicator" in currentNode:
					currentNode.indicator = "target"
		"moveObject":
			var targetLocPos = targetLocation.global_position
			targetLocPos.y = 0
			if botPos.distance_to(targetLocPos) < locTolerance:
				location = "drop"
				dropObject(targetObj, delta)
				if !palletGrabbed:
					clearPath()
					
					targetObj = null
					targetLocation = null
					currentTask = "idle"
					
					
				return
			else:
				location = "movement"
				if !pathNodes.is_empty():
					return
				var markA = pathManager.findClosest(self)
				var markB = pathManager.findClosest(targetLocation)
				#print(markA,markB)
				pathNodes = pathManager.getPath(markA, markB)
				pathNodes.append(targetLocation)
				currentNode = pathNodes[0]
				if "indicator" in currentNode:
					currentNode.indicator = "target"

func moveTo(delta):
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
	elif botPos.distance_to(curNodePos) > locTolerance:
		global_position = global_position.move_toward(curNodePos, moveSpeed * delta)
		return

func clearPath():
	pathManager.clearPath(pathNodes)
	pathNodes.clear()
	currentPathPos = 0
	rotateToFace = true
	currentNode = null
	previousNode = null

func getNextNode():
	currentPathPos += 1
	if currentPathPos < pathNodes.size():
		if previousNode != null and "indicator" in previousNode:
			previousNode.indicator = "plain"
		previousNode = currentNode
		currentNode = pathNodes[currentPathPos]
		rotateToFace = true
		if "indicator" in currentNode:
			currentNode.indicator = "target"

func assignTask(object, destination, label):
	targetObj = object
	targetLocation = destination
	currentTask = label
	
	pathManager.clearPath(pathNodes)
	pathNodes.clear()
	currentPathPos = 0
	currentNode = null
	previousNode = null

func grabObject(grabObj, delta):
	var currentRad = deg_to_rad(rotation_degrees.y)
	var angleRad = deg_to_rad(grabObj.rotation_degrees.y)
	var angleTolerance = .05
	
	if abs(angle_difference(angleRad, currentRad)) > angleTolerance:
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
		return
	elif !palletGrabbed:
		moveSpeed = moveSpeed/2
		rotationSpeed = rotationSpeed/2
		palletGrabbed = true
	
		grabObj.reparent(self)
		grabObj.place()
		grabObj.global_transform = global_transform

func dropObject(grabObj, delta):
	var currentRad = deg_to_rad(rotation_degrees.y)
	var angleRad = deg_to_rad(targetLocation.rotation_degrees.y)
	var angleTolerance = .05
	var root = get_tree().current_scene
	
	if abs(angle_difference(angleRad, currentRad)) > angleTolerance:
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
		return
	elif palletGrabbed:
		moveSpeed = moveSpeed*2
		rotationSpeed = rotationSpeed*2
		palletGrabbed = false
	
		grabObj.reparent(root)
		grabObj.place()
		grabObj.global_transform = global_transform
