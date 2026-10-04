extends Node2D

class_name BodySegment

var current_pos: Vector2

func move_to(destination: Vector2):
	# moves the body segment to the passed destination
	# returns the old position of the body segment
	# offset by 8,8 as mentioned in the snake script
	var old_pos = current_pos
	current_pos = destination
	position = 16 * current_pos
	return old_pos
