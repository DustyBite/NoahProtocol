extends Node

# Export vars

@export var openPos = 0.45

@export var autoClose: bool = true
@export var doorSpeed: float = 0.1

@export var closeDelay: float = 5.0

@export var unlockable: bool = true

# Onready var

@onready var leftDoor := $leftDoor
@onready var rightDoor := $rightDoor

@onready var acTimer: Timer = $autoCloseTimer

# Basic var

var closePos = 0.0
var targetPos = 0.0

var doorOpen: bool = false
var doorBlocked: bool = false

var locked: bool = false

func _ready() -> void:
	if !unlockable:
		locked = true
	
	acTimer.wait_time = closeDelay

func _process(_delta: float) -> void:
	leftDoor.position.x = lerp(leftDoor.position.x, targetPos, doorSpeed)
	rightDoor.position.x = lerp(rightDoor.position.x, -targetPos, doorSpeed)

func lock():
	if unlockable:
		locked = !locked

func openClose():
	if locked:
		return
	
	if doorOpen and !doorBlocked:
		targetPos = closePos
		doorOpen = false
	else:
		targetPos = openPos
		if autoClose:
			acTimer.start()
		doorOpen = true

func _on_timer_timeout():
	if !doorBlocked and !locked:
		targetPos = closePos
		doorOpen = false

func _on_area_3d_body_entered(_body: Node3D) -> void:
	#print("Enter")
	doorBlocked = true

func _on_area_3d_body_exited(_body: Node3D) -> void:
	#print("Exit")
	doorBlocked = false
	if autoClose:
		acTimer.start()
