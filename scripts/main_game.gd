extends Node

var pos_array = [
	Vector2(60, 600),
	Vector2(360, 600),
	Vector2(685, 600),
	Vector2(95, 820),
	Vector2(360, 820),
	Vector2(660, 820),
]
var game_log
var score
var removed_element
var removed_element_value
var is_gameover

func _ready():
	
	game_log = []
	score = 0
	is_gameover = false
	
	$ObstacleTimer.start()
	$CollectablesTimer.start()
	
	removed_element = 4
	removed_element_value = pos_array[removed_element]
	pos_array.remove(removed_element)

#func _process(delta):
#	pass

func spawnPoin():
	
	var chosen_pos: int
	var collectable = load("res://object scene/game/Collectables.tscn").instance()
	
	call_deferred("add_child", collectable)
	call_deferred("move_child", collectable, 3)
	
	randomize()
	chosen_pos = randi() % pos_array.size()
	collectable.position = pos_array[chosen_pos]
	
	pos_array.append(removed_element_value)
	
	collectable.connect("collect_poin", self, "on_Collectables_collect_poin")
	#$Collectables.position = pos_array[chosen_pos]
	
	removed_element = chosen_pos
	removed_element_value = pos_array[removed_element]
	pos_array.remove(chosen_pos)


func on_ExitButton_pressed():
	
	get_tree().change_scene("res://main scene/[R] Menu.tscn")
	pass # Replace with function body.

func on_Collectables_collect_poin():
	
	score =  score + 1
	$HUD/ScoreContainer/ScoreValue.text = str(score)
	
	var log_element = {
		"date" : $HTTPRequest.getDate(),
		"score" : score,
		"status" : "ALIVE"
	}
	
	game_log.append(log_element)
	$CollectablesTimer.start()

func on_CollectablesTimer_timeout():
	
	if is_gameover == false:
		spawnPoin()
		$CollectablesTimer.stop()
	else:
		pass
	
	pass # Replace with function body.

func on_Obstacles_game_over():
	
	var log_element = {
		"date" : $HTTPRequest.getDate(),
		"score" : score,
		"status" : "DEAD"
	}
	
	is_gameover = true
	game_log.append(log_element)
	
	$HTTPRequest.connect("request_completed", self, "on_Update_Score_request_complete")
	$HTTPRequest.UPDATE_ScoreData(globalVariables.user_data.id, score, game_log)
	
	$HUD/ScoreContainer.visible = false
	$HUD/FinalPanelContainer.visible = true
	
	$HUD/FinalPanelContainer/BoxContainer/ScoreContainer/Container/Score.text = str(score)
	$CollectablesTimer.stop()
	$ObstacleTimer.stop()
	pass

func on_ObstacleTimer_timeout():
	
	$Path2D/PathFollow2D.offset = randi()

	var obstacle = load("res://object scene/game/Obstacles.tscn").instance()
	add_child(obstacle)

	var direction = $Path2D/PathFollow2D.rotation + PI / 2

	obstacle.position = $Path2D/PathFollow2D.position
	direction += rand_range(-PI / 8, PI / 8)
	obstacle.rotation = direction

	obstacle.linear_velocity = Vector2(rand_range(obstacle.min_speed, obstacle.max_speed), 0)
	obstacle.linear_velocity = obstacle.linear_velocity.rotated(direction)

	obstacle.connect("game_over", self, "on_Obstacles_game_over")
	pass


func on_Update_Score_request_complete(_result, _response_code, _headers, body):
	
	var res = JSON.parse(body.get_string_from_utf8())
	var data = res.result
	
	if (_response_code == 200) :
		
		$HUD/FinalPanelContainer/BoxContainer/ScoreContainer/Container/HighScore.text = str(data.result.user_highscore)
		$HTTPRequest.disconnect("request_completed", self, "on_Update_Score_request_complete")
		pass
	else :
		pass
	pass


