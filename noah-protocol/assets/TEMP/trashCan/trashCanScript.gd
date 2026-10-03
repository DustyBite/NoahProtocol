extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("drink") or body.is_in_group("food"):
		if !body.full:
			body.queue_free()
