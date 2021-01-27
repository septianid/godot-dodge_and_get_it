extends RigidBody2D

signal game_over

export var min_speed = 250
export var max_speed = 400

func _ready():
	
	$AnimatedSprite.flip_h = true

func _process(delta):
	
	if (position.x > 740 || position.x < -20) || position.y > 1300:
		queue_free()
	
#	if position.x > 1300:
#		queue_free()

#func on_VisibilityNotifier2D_screen_exited():
#
#	print("Destroy")


func on_Obstacles_body_entered(body):
	
	body.queue_free()
	emit_signal("game_over")
	pass # Replace with function body.
