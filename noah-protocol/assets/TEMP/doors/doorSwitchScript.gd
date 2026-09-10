extends InteractableStatic

@onready var switch := $switch
var switchRestPos = .05
var switchPressPos = .025
var targetPos = .05

@onready var doorMain = $".."

func _process(_delta: float) -> void:
	switch.position.z = lerp(switch.position.z, targetPos, .1)

func interact(_body):
	doorMain.openClose()
	
	targetPos = switchPressPos
	await get_tree().create_timer(1.0).timeout
	targetPos = switchRestPos
