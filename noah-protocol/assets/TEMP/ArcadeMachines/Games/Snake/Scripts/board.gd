extends Control

class_name SnakeBoard

@export var fruit_count = 1
@export var board_size = 25
var game_won
@onready var snake: Node2D = $Snake
@onready var fruits: Node2D = $Fruits
@onready var current_score: Label = $Scorecards/Current
@onready var best_score: Label = $Scorecards/Best
@onready var game_over_screen: Node2D = $GameOverScreen
@onready var game_over_text: Label = $GameOverScreen/GameOver
@onready var you_win_text: Label = $GameOverScreen/YouWin
@onready var fruit_scene = preload("res://assets/TEMP/ArcadeMachines/Games/Snake/Scenes/fruit.tscn")

func _ready():
	# game setup
	for i in range(fruit_count):
		spawn_fruit()
	update_score()
	update_best()
	game_over_screen.hide()
	game_won = false

func _input(event: InputEvent) -> void:
	# play again and quit actions on game over/win screen
	if event.is_action_pressed("interact") and snake.game_active and not snake.alive:
		play_again()
	
	#if event.is_action_pressed("quit") and snake.game_active and not snake.alive:
		#get_tree().quit()

func fruit_check(pos):
	# checks all currently spawned fruits for if pos is already occupied
	for fruit in fruits.get_children():
		if pos == fruit.pos:
			fruit.queue_free()
			return true
	return false

func spawn_fruit():
	# spawns a new fruit, only if a new fruit would fit
	if fruits.get_child_count() + snake.current_length >= board_size * board_size:
		print("full")
		return
	var new_fruit = fruit_scene.instantiate()
	var new_fruit_pos = get_new_empty_pos()
	new_fruit.move_to(new_fruit_pos)
	fruits.add_child(new_fruit)

func get_new_empty_pos():
	# randomly selects a spot on the board
	# checks whether the snake, then the fruits to see if the spot is empty
	# repeats until an empty spot is found, returns that
	# will loop infinitely if called when the board is full
	var empty = false
	var new_pos : Vector2
	while !empty:
		new_pos = Vector2(randi() % board_size, randi() % board_size)
		if new_pos not in snake.occupied_positions:
			empty = true
		if fruits.get_child_count() > 0:
			for fruit in fruits.get_children():
				if new_pos == fruit.pos:
					empty = false
	return new_pos

func update_score():
	# update score display
	current_score.text = "Score: " + str(snake.score)

func update_best():
	# update best score display. BestScores is the name of the global script
	best_score.text = "Best: " + str(BestScores.snake_highscore)

func game_over():
	# game end code, displays the proper game over screen, updates highscore if necessary
	if game_won:
		you_win_text.show()
		game_over_text.hide()
	else:
		you_win_text.hide()
		game_over_text.show()
	game_over_screen.show()
	if snake.score > BestScores.snake_highscore:
		BestScores.snake_highscore = snake.score
	update_best()

func play_again():
	# reload the scene to play again
	get_tree().reload_current_scene()

func win():
	# win screen setup
	game_won = true
	snake.game_active = false
	game_over()
