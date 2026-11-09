extends Node

@export var lightArray: Array[Node]

@export var lightBrightness: Array[float] = [2.0, 1.0, 0.5]


var lightState: bool = true
var lightLevel = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for light in lightArray:
		if lightState:
			light.light_energy = lightBrightness[lightLevel]
		elif !lightState:
			light.light_energy = 0

func dim():
	if lightLevel + 1 == lightBrightness.size():
		lightLevel = 0
	else:
		lightLevel += 1
