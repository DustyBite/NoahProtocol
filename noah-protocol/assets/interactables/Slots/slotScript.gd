extends Node3D
class_name ItemSlot

@onready var marker: Marker3D = $Marker3D
@onready var area: Area3D = $Area3D

@export var slotType: String

@onready var ghostMesh := $meshGhost

var slottedItem = null

func loadItem(item, _bool):
	var I = item.instantiate()
	slotItem(I)

func InteractOff():
	if slottedItem != null:
		slottedItem.set_collision_layer_value(8, false)

func InteractOn():
	if slottedItem != null:
		slottedItem.set_collision_layer_value(8, true)

func showSlot():
	area.monitoring = true

func hideSlot():
	area.monitoring = false

func slotItem(body) -> void:
	ghostMesh.visible = false
	#print("Slot Item: ", body)
	slottedItem = body
	var bodyParent = body.get_parent()
	if bodyParent != null:
		bodyParent.remove_child(body)
	add_child(body)
	body.place()
	body.global_position = marker.global_position
	body.global_rotation = marker.global_rotation
	body.slot = self  # <-- set the back reference

func clearSlot() -> void:
	#print("Clear Slot")
	if slottedItem:
		slottedItem.unplace()
		var savedPosition = slottedItem.global_position
		#var savedRotation = slottedItem.global_rotation
		remove_child(slottedItem)
		get_tree().current_scene.add_child(slottedItem)
		slottedItem.global_position = savedPosition
		#slottedItem.global_rotation = savedRotation
		slottedItem = null
		area.monitoring = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if slottedItem != null:
		return
	if "type" in body and body.type != slotType:
		return
	if "placable" in body and body.placable:
		body.slot = self
		ghostMesh.visible = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	ghostMesh.visible = false
	if "type" in body and body.type != slotType:
		return
	if "placable" in body and body.placable:
		if slottedItem != body and body.slot == self:  # if its not slotted here, clear the reference
			body.slot = null
			#print("Exit")
