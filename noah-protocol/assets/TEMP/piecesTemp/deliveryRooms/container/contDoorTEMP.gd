extends Node

var open: bool = true

func _process(_delta: float) -> void:
	$MeshInstance3D24.visible = !open
	$StaticBody3D/CollisionShape3D.disabled = open
