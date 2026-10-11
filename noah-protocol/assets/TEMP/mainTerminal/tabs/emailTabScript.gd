extends Node

# Onready var

@onready var emailTabs: Array = [
	$emails/email1,
	$emails/email2,
	$emails/email3,
	$emails/email4,
]

@onready var emailButtons: Array = [
	$buttons/email1,
	$buttons/email2,
	$buttons/email3,
	$buttons/email4,
]

# Basic var

var currentEmail: int = 0
var currentButton: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emailButtons[currentButton].grab_focus()
	emailButtons[currentButton].pressed.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	showEmail(currentEmail)

func cycleEmail(value):
	currentButton += value
	if currentButton < 0:
		currentButton = emailButtons.size()-1
	elif currentButton > emailButtons.size()-1:
		currentButton = 0
	
	emailButtons[currentButton].grab_focus()
	emailButtons[currentButton].pressed.emit()

func showEmail(value):
	if value == 0:
		for email in emailTabs:
			email.visible = false
	else:
		for email in emailTabs:
			email.visible = false
		
		emailTabs[value-1].visible = true

func _on_email_1_pressed() -> void:
	currentEmail = 1

func _on_email_2_pressed() -> void:
	currentEmail = 2

func _on_email_3_pressed() -> void:
	currentEmail = 3

func _on_email_4_pressed() -> void:
	currentEmail = 4
