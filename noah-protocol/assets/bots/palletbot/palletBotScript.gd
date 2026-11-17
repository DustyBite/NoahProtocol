extends botBase
class_name palletBot

var palletGrabbed: bool = false


func runTask(delta) -> void:
	match currentTask:
		"grabObject":
			if isAtTarget(targetObj):
				location = "grab"
				grabObject(targetObj, delta)
				if palletGrabbed:
					clearPath()
					currentTask = "moveObject"
			else:
				startPathTo(targetObj)
		"moveObject":
			if isAtTarget(targetLocation):
				location = "drop"
				dropObject(targetObj, delta)
				if !palletGrabbed:
					clearPath()
					targetObj = null
					targetLocation = null
					currentTask = "idle"
			else:
				startPathTo(targetLocation)


func grabObject(grabObj, delta) -> void:
	var currentRad = deg_to_rad(rotation_degrees.y)
	var angleRad = deg_to_rad(grabObj.rotation_degrees.y)
	var angleTolerance = .05

	if abs(angle_difference(angleRad, currentRad)) > angleTolerance:
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
		return
	elif !palletGrabbed:
		moveSpeed = moveSpeed / 2
		rotationSpeed = rotationSpeed / 2
		palletGrabbed = true

		grabObj.reparent(self)
		grabObj.place()
		grabObj.global_transform = global_transform


func dropObject(grabObj, delta) -> void:
	var currentRad = deg_to_rad(rotation_degrees.y)
	var angleRad = deg_to_rad(targetLocation.rotation_degrees.y)
	var angleTolerance = .05
	var root = get_tree().current_scene

	if abs(angle_difference(angleRad, currentRad)) > angleTolerance:
		rotation_degrees.y = rad_to_deg(rotate_toward(currentRad, angleRad, rotationSpeed * delta))
		return
	elif palletGrabbed:
		moveSpeed = moveSpeed * 2
		rotationSpeed = rotationSpeed * 2
		palletGrabbed = false

		grabObj.reparent(root)
		grabObj.place()
		grabObj.global_transform = global_transform
