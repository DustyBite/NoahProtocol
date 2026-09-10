extends Node3D

@export var container: Node3D

func interact():
	if container != null and container.has_method("swapContainer"):
		container.swapContainer()
