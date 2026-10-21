extends CharacterBody2D

@export var speed: float = 400.0
@export var maxBounceAngle: float = 60.0
var direction: Vector2 = Vector2(1, 1).normalized()
var moving = true

var pingRoot: Node2D

var startDirection = randf_range(-1, 1)

func _ready() -> void:
	pingRoot = get_parent()
	
	match pingRoot.winningPlayer:
		0:
			startDirection = randf_range(-1, 1)
		1:
			startDirection = -1
		2:
			startDirection = 1
	
	direction = Vector2(startDirection, randf_range(-.1, .1)).normalized()

func _physics_process(delta: float) -> void:
	if pingRoot.movementPaused:
		return
	
	var collision = move_and_collide(direction * (speed * pingRoot.gameSpeed) * delta)
	
	if collision:
		var collider = collision.get_collider()
		
		# Check if we hit a paddle (adjust the group/type check as needed)
		if collider.is_in_group("paddle"):
			collider.hitSound()
			direction = calculatePaddleBounce(collision, collider)
		else:
			# Normal bounce for walls
			direction = direction.bounce(collision.get_normal())

func calculatePaddleBounce(collision: KinematicCollision2D, paddle: Node2D) -> Vector2:
	# Get where on the paddle we hit (0 = center, -1 = top, 1 = bottom)
	var paddleHeight = 60.0  # Adjust based on your paddle's actual height
	var collisionPoint = collision.get_position().y
	var paddleCenter = paddle.global_position.y
	
	var hitOffset = (collisionPoint - paddleCenter) / (paddleHeight / 2.0)
	hitOffset = clamp(hitOffset, -1.0, 1.0)
	
	# Calculate bounce angle based on hit position
	var bounceAngleRad = deg_to_rad(maxBounceAngle) * hitOffset
	
	# Determine which direction to shoot (left or right)
	var directionX = sign(paddle.global_position.x - global_position.x) * -1
	
	# Create new direction vector
	var newDirection = Vector2(directionX, tan(bounceAngleRad)).normalized()
	
	return newDirection
