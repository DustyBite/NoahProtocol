extends Node2D

var movementPaused = true
var gameSpeed = 1.0
@export var speedIncrease = .001

@onready var playerArray = [$bluePaddle,$redPaddle]
@onready var playerScoreCard = [$score/p1Score,$score/p2Score]
var score = [0,0]
var winningPlayer = 0
var activePlayer


func _ready() -> void:
	newRound()

var pingBallInstance = preload("res://assets/TEMP/ArcadeMachines/Games/Ping/pingBall.tscn")
var activeBall: CharacterBody2D = null

func _process(_delta: float) -> void:
	if movementPaused:
		return
	
	gameSpeed += speedIncrease

func newRound():
	movementPaused = true
	randomize()
	gameSpeed = 1.0
	if activeBall != null:
		activeBall.queue_free()
		activeBall = null
	
	activeBall = pingBallInstance.instantiate()
	#activeBall.moving = false
	activeBall.position = Vector2(160, 120)
	call_deferred("add_child",activeBall)
	
	checkScore()
	
	playerArray[0].isServing = false
	playerArray[1].isServing = false
	
	match winningPlayer:
		0:
			print("Tie!")
			var rI = randi() % playerArray.size()
			activePlayer = playerArray[rI]
			playerArray[rI].isServing = true
		1:
			print("Player 1 Winning!")
			activePlayer = playerArray[0]
			playerArray[0].isServing = true
		2:
			print("Player 2 Winning!")
			activePlayer = playerArray[1]
			playerArray[1].isServing = true
	
	playerArray[0].call_deferred("find_ball")
	playerArray[1].call_deferred("find_ball")

func checkScore():
	playerScoreCard[0].score = score[0]
	playerScoreCard[1].score = score[1]
	
	if score[0] == score[1]:
		winningPlayer = 0
	elif score[0] > score[1]:
		winningPlayer = 1
	elif score[0] < score[1]:
		winningPlayer = 2


func _on_goal_a_body_entered(body: Node2D) -> void:
	if body == activeBall:
		#$audio/PingM1.play()
		
		if score[1] == 9:
			score[1] = 0
		else:
			score[1] += 1
		newRound()


func _on_goal_b_body_entered(body: Node2D) -> void:
	if body == activeBall:
		#$audio/PingM1.play()
		
		if score[0] == 9:
			score[0] = 0
		else:
			score[0] += 1
		newRound()
