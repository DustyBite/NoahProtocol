extends InteractableDynamic

@onready var boltGroup := $bolts

var boltArray: Array
var interactable: bool = true

func _ready() -> void:
	super._ready()
	
	getBolts()

func _process(_delta: float) -> void:
	checkBolted()

func checkBolted():
	for bolt in boltArray:
		if !bolt.unbolted:
			interactOff()
			break
		else:
			interactOn()

func interactOn():
	if interactable:
		return
	
	interactable = true
	self.set_collision_layer_value(8, true)

func interactOff():
	if !interactable:
		return
	
	interactable = false
	self.set_collision_layer_value(8, false)

func getBolts():
	for bolt in boltGroup.get_children():
		boltArray.append(bolt)
