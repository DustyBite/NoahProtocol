extends Node

@onready var leftDoor := $leftDoor
@onready var rightDoor := $rightDoor
@export var openPos = 0.5
var closePos = 0.0
var targetPos = 0.0

@export var doorOpen: bool = true
var doorBlocked: bool = false

@export var autoClose: bool = true
@export var doorSpeed: float = 0.1

@onready var acTimer: Timer = $autoCloseTimer
@export var closeDelay: float = 5.0

func _ready() -> void:
	acTimer.wait_time = closeDelay
	if doorOpen == false:
		openClose()

func _process(_delta: float) -> void:
	leftDoor.position.x = lerp(leftDoor.position.x, targetPos, doorSpeed)
	rightDoor.position.x = lerp(rightDoor.position.x, -targetPos, doorSpeed)

func openClose():
	if doorOpen and !doorBlocked:
		targetPos = closePos
		doorOpen = false
	else:
		targetPos = openPos
		if autoClose:
			acTimer.start()
		doorOpen = true

func _on_timer_timeout():
	if !doorBlocked:
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
