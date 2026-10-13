extends InteractableStatic

@onready var camPos = $Marker3D

func interact(body):
	if body.has_method("sleep"):
		body.sleep(camPos)
