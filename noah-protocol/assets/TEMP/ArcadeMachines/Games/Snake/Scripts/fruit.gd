extends Node2D

class_name Fruit

@export var pos: Vector2

func move_to(destination):
	# sets the position of the fruit. default is 0,0
	# main game scene has the fruit container offset by 8,8 because the object origin is the center
	pos = destination
	position = pos * 16
