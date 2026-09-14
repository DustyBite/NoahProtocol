extends Node

@export_group("DEVTEST")

var astar = AStar3D.new()
var nodeToId = {}

func _ready() -> void:
	var markers = get_children()
	
	for marker in markers:
		var id = astar.get_available_point_id()
		astar.add_point(id, marker.global_position)
		nodeToId[marker] = id
	
	for marker in markers:
		for neighbor in marker.neighbors:
			astar.connect_points(nodeToId[marker], nodeToId[neighbor], false)

func findClosest(obj):
	var closestMarker = null
	var objPos = obj.global_position
	for marker in nodeToId:
		if closestMarker == null:
			closestMarker = marker
		else:
			var distanceA = objPos.distance_to(closestMarker.global_position)
			var distanceB = objPos.distance_to(marker.global_position)
			if distanceA > distanceB:
				closestMarker = marker
	return closestMarker

func getPath(fromMarker, toMarker):
	var fromId = nodeToId[fromMarker]
	var toId = nodeToId[toMarker]
	var idPath = astar.get_id_path(fromId, toId)
	
	var nodePath = []
	for id in idPath:
		var marker = nodeToId.find_key(id)
		marker.indicator = "active"
		nodePath.append(marker)
	return nodePath

func clearPath(nodePath):
	for marker in nodePath:
		marker.indicator = "plain"
