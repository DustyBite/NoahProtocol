extends Node2D

class_name Snake

enum directions {UP, RIGHT, DOWN, LEFT}

@export var start_direction = directions.RIGHT
@export var start_length = 3
@export var start_pos = Vector2(3, 12)
@export var move_delay = 0.5
@export var board: SnakeBoard
var alive
var game_active
var current_direction
var current_length
var current_head_pos
var occupied_positions = []
var moved_since_turn
var time_since_move
var score
@onready var head: Node2D = $Head
@onready var head_alive: Sprite2D = $Head/HeadAlive
@onready var head_dead: Sprite2D = $Head/HeadDead
@onready var body: Node2D = $Body
@onready var body_segment = preload("res://assets/TEMP/ArcadeMachines/Games/Snake/Scenes/body_segment.tscn")

func _ready():
	# variable setup
	current_direction = start_direction
	current_length = start_length
	alive = false
	game_active = false
	head_alive.show()
	head_dead.hide()
	moved_since_turn = false
	time_since_move = 0.0
	score = 0
	
	# places the head. note that posision is the center of the object
	# in the 2d scene, the snake object is offset to 8,8 to place it properly
	# anything that changes an objects position relies on this
	current_head_pos = start_pos
	head.position = start_pos * 16
	occupied_positions.append(current_head_pos)
	
	# spawns body segments to fill out the body based on start_length
	# places each new segment behind the head in a straight line
	# as such, when choosing start position, make sure a straight line of start_length units fits
	var distance_from_head = Vector2(0,0)
	for i in range(start_length - 1):
		body.add_child(body_segment.instantiate())
	match start_direction:
		directions.UP:
			head.rotation_degrees = 0
			for segment in body.get_children():
				distance_from_head += Vector2(0, 1)
				segment.move_to(start_pos + distance_from_head)
				occupied_positions.append(start_pos + distance_from_head)
		directions.RIGHT:
			head.rotation_degrees = 90
			for segment in body.get_children():
				distance_from_head += Vector2(-1, 0)
				segment.move_to(start_pos + distance_from_head)
				occupied_positions.append(start_pos + distance_from_head)
		directions.DOWN:
			head.rotation_degrees = 180
			for segment in body.get_children():
				distance_from_head += Vector2(0, -1)
				segment.move_to(start_pos + distance_from_head)
				occupied_positions.append(start_pos + distance_from_head)
		directions.LEFT:
			head.rotation_degrees = 270
			for segment in body.get_children():
				distance_from_head += Vector2(1, 0)
				segment.move_to(start_pos + distance_from_head)
				occupied_positions.append(start_pos + distance_from_head)
	
	

func _process(delta: float) -> void:
	# moves the snake every move_delay seconds while the game is active
	if not alive or not game_active:
		return
	time_since_move += delta
	if time_since_move >= move_delay:
		move()
		time_since_move = 0.0

func _input(event: InputEvent) -> void:
	# input processing
	if event.is_action_pressed("interact") and not game_active:
		start_game()
	if not alive:
		return
	if event.is_action_pressed("navUp") or event.is_action_pressed("forward"):
		turn_up()
	elif event.is_action_pressed("navRight") or event.is_action_pressed("right"):
		turn_right()
	elif event.is_action_pressed("navDown") or event.is_action_pressed("back"):
		turn_down()
	elif event.is_action_pressed("navLeft") or event.is_action_pressed("left"):
		turn_left()

func start_game():
	alive = true
	game_active = true

# functions to turn. only allows one turn to be processed between moves
# only allows the player to turn 90 degrees from their current direction
func turn_up():
	if not moved_since_turn or current_direction == directions.UP or current_direction == directions.DOWN:
		return
	current_direction = directions.UP
	head.rotation_degrees = 0
	moved_since_turn = false

func turn_right():
	if not moved_since_turn or current_direction == directions.RIGHT or current_direction == directions.LEFT:
		return
	current_direction = directions.RIGHT
	head.rotation_degrees = 90
	moved_since_turn = false

func turn_down():
	if not moved_since_turn or current_direction == directions.DOWN or current_direction == directions.UP:
		return
	current_direction = directions.DOWN
	head.rotation_degrees = 180
	moved_since_turn = false

func turn_left():
	if not moved_since_turn or current_direction == directions.LEFT or current_direction == directions.RIGHT:
		return
	current_direction = directions.LEFT
	head.rotation_degrees = 270
	moved_since_turn = false

func move():
	# find new position of head
	var new_pos
	match current_direction:
		directions.UP:
			new_pos = current_head_pos + Vector2(0, -1)
		directions.RIGHT:
			new_pos = current_head_pos + Vector2(1, 0)
		directions.DOWN:
			new_pos = current_head_pos + Vector2(0, 1)
		directions.LEFT:
			new_pos = current_head_pos + Vector2(-1, 0)
	# make sure the new position is a legal move
	if new_pos.x < 0 or new_pos.x > board.board_size - 1 or new_pos.y < 0 or new_pos.y > board.board_size - 1:
		# wall collision
		game_over()
		return
	if new_pos in occupied_positions:
		# self collision
		game_over()
		return
	# moves the body segments, details in the function
	var next_tail = move_body_segments(current_head_pos)
	# sets new head position and adds it to occupied positions
	current_head_pos = new_pos
	occupied_positions.push_front(new_pos)
	head.position = new_pos * 16
	# check for a fruit, if there is one, increase body length
	# otherwise, remove the last tail position from the array
	if board.fruit_check(new_pos):
		increase_length(next_tail)
		if current_length == (board.board_size * board.board_size):
			board.win()
		else:
			board.spawn_fruit()
	if occupied_positions.size() > current_length:
		occupied_positions.remove_at(current_length)
	moved_since_turn = true

func move_body_segments(pos):
	# loops through the body segments, moving each one to the previous one's location
	# returns the position of the last body segment, for use in increase_length
	var destination = pos
	for segment in body.get_children():
		destination = segment.move_to(destination)
	return destination

func increase_length(pos):
	# spawns a new body segment, placing it at the passed location
	# also updates the score and scoreboard
	current_length += 1
	var new_segment = body_segment.instantiate()
	body.add_child(new_segment)
	new_segment.move_to(pos)
	score += 1
	board.update_score()

func game_over():
	# final steps for when a game is lost
	alive = false
	head_dead.show()
	head_alive.hide()
	board.game_over()
