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

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	checkTask()

func _physics_process(delta: float) -> void:
	
	if location == "movement":
		moveTo(delta)

func checkTask():
	match currentTask:
		"idle":
			var botPos = global_position
			botPos.y = 0
			var chargerPos = chargerObj.global_position
			chargerPos.y = 0
			if botPos.distance_to(chargerPos) < locTolerance:
				if location == "charger":
					return
				location = "charger"
				pathManager.clearPath(pathNodes)
				pathNodes.clear()
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
				currentNode.indicator = "target"

func moveTo(delta):
	if pathNodes.is_empty():
		return
	
	var botPos = global_position
	var curNodePos = currentNode.global_position
	curNodePos.y = botPos.y
	if botPos.distance_to(curNodePos) < locTolerance:
		getNextNode()
	elif botPos.distance_to(curNodePos) > locTolerance:
		global_position = global_position.move_toward(curNodePos, moveSpeed * delta)
		return

func getNextNode():
	currentPathPos += 1
	if currentPathPos < pathNodes.size():
		if previousNode != null and "indicator" in previousNode:
			previousNode.indicator = "plain"
		previousNode = currentNode
		currentNode = pathNodes[currentPathPos]
		if "indicator" in currentNode:
			currentNode.indicator = "target"
