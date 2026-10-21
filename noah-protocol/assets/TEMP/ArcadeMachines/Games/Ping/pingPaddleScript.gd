extends StaticBody2D

@export var speed: float = 300.0
@export var padding: float = 160.0
@export var redPaddle: bool = false
@onready var bpSprite = $PingBluePaddle
@onready var rpSprite = $PingRedPaddle
var isServing: bool = false

# AI Settings
@export var isAi: bool = false
@export_enum("Easy", "Medium", "Hard") var aiDifficulty: int = 1

var pingRoot: Node2D
var topLimit: float
var bottomLimit: float

# Temp Movement Inputs
@export var altMovement: bool = false
var up = "up"
var down = "down"

# AI variables
var ball: Node2D = null
var aiReactionTime: float = 0.0
var aiTargetY: float = 0.0
var aiUpdateTimer: float = 0.0

# AI difficulty settings
var aiSettings = {
	0: { # Easy
		"reactionDelay": 0.3,
		"updateFrequency": 0.2,
		"accuracy": 0.6,
		"maxSpeedMultiplier": 0.6
	},
	1: { # Medium
		"reactionDelay": 0.15,
		"updateFrequency": 0.1,
		"accuracy": 0.8,
		"maxSpeedMultiplier": 0.85
	},
	2: { # Hard
		"reactionDelay": 0.05,
		"updateFrequency": 0.05,
		"accuracy": 0.95,
		"maxSpeedMultiplier": 1.0
	}
}

func _ready() -> void:
	if redPaddle:
		rpSprite.visible = true
		bpSprite.visible = false
	
	pingRoot = get_parent()
	
	if altMovement:
		up = "upArrow"
		down = "downArrow"
	
	# Get viewport size and set limits
	topLimit = padding + 25
	bottomLimit = 240 - (padding + 15)
	
	# Find the ball if AI
	if isAi:
		call_deferred("find_ball")

func find_ball() -> void:
	if isServing:
		call_deferred("serve")
	ball = pingRoot.activeBall

func _physics_process(delta: float) -> void:
	var direction: float = 0.0
	
	if isAi:
		direction = getAiDirection(delta)
	else:
		direction = getPlayerDirection()
	
	position.y += direction * (speed * pingRoot.gameSpeed) * delta
	position.y = clamp(position.y, topLimit, bottomLimit)

func getPlayerDirection() -> float:
	if Input.is_action_pressed("interact") and isServing:
		pingRoot.movementPaused = false
	
	var direction: float = 0.0
	
	if Input.is_action_pressed("navUp"):
		direction = -1.0
	elif Input.is_action_pressed("navDown"):
		direction = 1.0
	
	return direction

func getAiDirection(delta: float) -> float:
	if not ball:
		return 0.0
	
	var settings = aiSettings[aiDifficulty]
	
	# Update AI target periodically (simulates reaction time)
	aiUpdateTimer -= delta
	if aiUpdateTimer <= 0.0:
		aiUpdateTimer = settings["updateFrequency"]
		
		# Check if ball is moving towards this paddle
		var ballMovingTowardsUs = false
		if global_position.x < ball.global_position.x:
			# Paddle on left, ball moving left
			ballMovingTowardsUs = ball.direction.x < 0
		else:
			# Paddle on right, ball moving right
			ballMovingTowardsUs = ball.direction.x > 0
		
		if ballMovingTowardsUs:
			# Track the ball with some inaccuracy
			var accuracy_offset = randf_range(-50.0, 50.0) * (1.0 - settings["accuracy"])
			aiTargetY = ball.global_position.y + accuracy_offset
		else:
			# Return to center when ball is going away
			var viewport_center = get_viewport_rect().size.y / 2.0
			aiTargetY = viewport_center
	
	# Move towards target
	var distanceToTarget = aiTargetY - global_position.y
	var deadZone = 10.0
	
	if abs(distanceToTarget) < deadZone:
		return 0.0
	
	var direction = sign(distanceToTarget)
	
	# Apply speed multiplier for difficulty
	return direction * settings["maxSpeedMultiplier"]

func hitSound():
	pass
	#$FireM1.play(.3)

func serve():
	await get_tree().create_timer(1.0).timeout
	pingRoot.movementPaused = false
