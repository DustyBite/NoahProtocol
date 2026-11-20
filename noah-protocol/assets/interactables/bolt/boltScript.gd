extends InteractableStatic

@onready var mesh := $MeshInstance3D

var unbolted : bool = false

func interact(_body):
	unbolted = !unbolted
	
	mesh.visible = !unbolted
