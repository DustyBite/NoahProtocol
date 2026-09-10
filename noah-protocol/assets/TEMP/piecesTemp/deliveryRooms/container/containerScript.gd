extends Node

@export var deliveryContainer: bool = false

@onready var door := $door
@onready var pallet := preload("res://assets/TEMP/pallet/pallet.tscn")

var markerArray : Array

var palletArray : Array

func _ready():
	door.open = false
	
	for marker in $markers.get_children():
		markerArray.append(marker)
	
	if !deliveryContainer:
		deliverPallet()

func swapContainer():
	door.open = false
	await scanPallet()
	await removePallet()
	await deliverPallet()

func scanPallet():
	var total = 0
	for pall in palletArray:
		total += pall.getTotalPoints()
	await get_tree().create_timer(0.1).timeout
	Globals.pointTotal += total

func deliverPallet():
	for marker in markerArray:
		var pall = pallet.instantiate()
		var pos = marker.global_position
		get_tree().current_scene.add_child.call_deferred(pall)
		pall.set_deferred("global_position", pos)
	
	await get_tree().create_timer(1.5).timeout
	door.open = true

func removePallet():
	for pall in palletArray:
		pall.queue_free()
	await get_tree().create_timer(0.1).timeout

func _on_area_3d_body_entered(body: Node3D) -> void:
	if "type" in body and body.type == "pallet":
		#print("Enter", body)
		palletArray.append(body)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if "type" in body and body.type == "pallet":
		for pall in palletArray:
			if pall == body:
				palletArray.erase(body)
				#print("Exit", body)
				break
