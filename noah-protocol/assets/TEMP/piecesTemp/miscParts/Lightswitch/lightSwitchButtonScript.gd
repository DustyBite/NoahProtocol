extends InteractableStatic

# Export var

@export var switch : Node
@export var dim: bool = false

# Onready var

@onready var mainSwitchBody = $".."

# Basic Var

var switchRestPos: float
var switchPressPos: float
var targetPos: float

func _ready() -> void:
	super._ready()
	
	switchRestPos = switch.position.z
	targetPos = switchRestPos
	switchPressPos = switchRestPos -.015

func _process(_delta: float) -> void:
	switch.position.z = lerp(switch.position.z, targetPos, .1)

func interact(_body):
	if dim:
		mainSwitchBody.dim()
	else:
		mainSwitchBody.lightState = !mainSwitchBody.lightState 
	
	targetPos = switchPressPos
	await get_tree().create_timer(1.0).timeout
	targetPos = switchRestPos
