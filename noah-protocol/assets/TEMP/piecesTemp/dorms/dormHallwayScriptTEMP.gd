extends Node

const dormScene := preload("res://assets/TEMP/piecesTemp/dorms/dorm.tscn")
const dormClosed := preload("res://assets/TEMP/piecesTemp/dorms/dormClosed.tscn")

@onready var dormNodesObj := $dormNodes
var dormNodesArray : Array

var dormCount : int

func _ready() -> void:
	spawnDorm()

func spawnDorm():
	var nodeCount = dormNodesObj.get_child_count()
	dormCount = randi_range(0, 6)
	print(dormCount)
	
	var i = nodeCount
	while i > 0 :
		var markerPos = dormNodesObj.get_child(i-1)
		dormNodesArray.append(markerPos)
		i -= 1
	
	dormNodesArray.shuffle()
	
	i = nodeCount
	while i > 0 :
		var instance = null
		var markerPos = dormNodesArray[i-1]
		
		if dormCount > 0:
			instance = dormScene.instantiate()
			dormCount -= 1
		else:
			instance = dormClosed.instantiate()
		
		add_child(instance)
		instance.global_position = markerPos.global_position
		instance.global_rotation = markerPos.global_rotation
		i -= 1
