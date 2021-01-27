extends Area2D

signal collect_poin

func _ready():
	
	pass # Replace with function body.

#func _process(delta):
#	pass


func on_Collectables_body_entered(body):
	
	if body.get_name() == "Player":
		emit_signal("collect_poin")
		queue_free()
