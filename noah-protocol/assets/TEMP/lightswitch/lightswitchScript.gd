extends InteractableStatic

@onready var switch := $switch
var switchRestPos = .05
var switchPressPos = .025
var targetPos = .05

var status: bool = false

@export var mainLights : Node3D

func interact(_body):
	status = !status

func _process(_delta: float) -> void:
	checkLights()
	
	switch.position.z = lerp(switch.position.z, targetPos, .1)

func checkLights():
	if status:
		targetPos = switchPressPos
		mainLights.visible = true
	else:
		targetPos = switchRestPos
		mainLights.visible = false
