extends KinematicBody2D

#signal swiped(direction)
#signal swipe_cancel(startPos)

export(float, 1.0, 1.5) var MAX_DIAGONAL_SLOPE = 1.3
export(int) var speed = 200
export(int) var jump_speed = 500
export(int) var gravity = 1000
export(bool) var game_start = false

onready var velocity = Vector2()
onready var swipe_startPos = Vector2()
onready var timer = $SwipeTimer

func _input(event):
	
	if not event is InputEventScreenTouch:
		return
	
	if event.is_pressed():
		start_detection(event.position)
	elif not timer.is_stopped():
		end_detection(event.position)
	pass


func _ready():
	
	$AnimatedSprite.play("idle")
	pass # Replace with function body.


func _process(delta):
	velocity.y += gravity * delta

	move_and_slide(velocity, Vector2(0, -1))
	pass

	if is_on_floor():
		if game_start == true:
			$AnimatedSprite.animation = "move"
#			$AnimatedSprite.play("move")
		else:
			$AnimatedSprite.animation = "idle"
#			$AnimatedSprite.play("idle")

	if self.position.x > 730:
		self.position.x = -10

	if self.position.x < -10:
		self.position.x = 730


func start_detection(position):
	
	swipe_startPos = position
	timer.start()

func end_detection(position):
	
	timer.stop()
	var direction = (position - swipe_startPos).normalized()
	
	if abs(direction.x) + abs(direction.y) >= MAX_DIAGONAL_SLOPE:
		return

	if abs(direction.x) > abs(direction.y):
		
#		$AnimatedSprite.play("move")
		$AnimatedSprite.animation = "move"
		if direction.x > 0 && ((position.x - swipe_startPos.x) > 80):
			game_start = true
			$AnimatedSprite.flip_h = false
			velocity.x = speed
		elif direction.x < 0 && ((position.x - swipe_startPos.x) < -80):
			game_start = true
			$AnimatedSprite.flip_h = true
			velocity.x = -speed
		else:
			pass

	else:
		if direction.y < 0 && ((position.y - swipe_startPos.y) < -90):
			if is_on_floor():
#				$AnimatedSprite.play("jump")
				$AnimatedSprite.animation = "jump"
				velocity.y = -jump_speed
		else:
			pass
	#velocity = velocity.normalized() * speed
	pass
#
