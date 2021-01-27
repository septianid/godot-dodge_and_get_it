extends CanvasLayer

var guidePanel = preload("res://object scene/menu/Guide.tscn")
var tncPanel = preload("res://object scene/menu/Terms & Condition.tscn")
var leaderboardPanel = preload("res://object scene/menu/Leaderboard.tscn")

var user_info
var isAdValid
var closeLeaderboard

func _ready():
	
	showORHideButton(false)
	mainMenuStart()
	pass



func mainMenuStart():
	
	$MainContainer/UIContainer/Buttons/MarginTop/LifeBox/LifeLoader.play()
	$HTTPRequest.connect("request_completed", self, "on_GET_Info_request_completed")
	$HTTPRequest.GET_UserData()
	
	yield($HTTPRequest, "request_completed")
	
	adWatchChecking()
	pass

func drawLife():
	
	for _i in range(user_info.play_free):
		
		var life = preload("res://object scene/menu/Life.tscn")
		var lifeObject = life.instance()
		
		$MainContainer/UIContainer/Buttons/MarginTop/LifeBox.add_child(lifeObject)
		lifeObject.texture = load("res://assets/menu/LIFE.png")
		
	
	$MainContainer/UIContainer/Buttons/MarginTop/LifeBox/LifeLoader.stop()
	$MainContainer/UIContainer/Buttons/MarginTop/LifeBox/LifeLoader.visible = false
	
	pass

func adWatchChecking():
	
	if user_info.play_free == 0:
		
		if $HTTPRequest.getAdID() != null:
			
			$HTTPRequest.connect("request_completed", self, "on_GET_Validity_request_completed")
			$HTTPRequest.GET_CheckAdValidity()
			
			yield($HTTPRequest, "request_completed")
			
			if isAdValid == true:
				
				$HTTPRequest.connect("request_completed", self, "on_POST_Start_request_completed")
				$HTTPRequest.POST_ScoreData(true, true)
				pass
			else:
				
				drawLife()
				enableORDisableButton(false)
				showORHideButton(true)
				pass
			pass
		else:
			
			drawLife()
			enableORDisableButton(false)
			showORHideButton(true)
			pass
		pass
	else:
		
		drawLife()
		enableORDisableButton(false)
		showORHideButton(true)
		pass
	pass

func showORHideButton(isShow):
	
	$MainContainer/UIContainer/Buttons/PlayButton.visible = isShow
	$MainContainer/UIContainer/Buttons/GuideButton.visible = isShow
	$MainContainer/UIContainer/Buttons/LeaderboardButton.visible = isShow
	$MainContainer/UIContainer/Buttons/TnCButton.visible = isShow
	pass

func enableORDisableButton(isEnable):
	
	$MainContainer/UIContainer/Buttons/PlayButton.disabled = isEnable
	$MainContainer/UIContainer/Buttons/GuideButton.disabled = isEnable
	$MainContainer/UIContainer/Buttons/LeaderboardButton.disabled = isEnable
	$MainContainer/UIContainer/Buttons/TnCButton.disabled = isEnable
	pass

func showWarning(path):
	
	if path == "res://assets/menu/DM_PW.png":
		$WarningPanel/CloseButton.show()
	else:
		$WarningPanel/CloseButton.hide()
		pass
	
	$WarningPanel.show()
	$WarningPanel.get_stylebox("panel").texture = load(path)
	pass




func on_Play_Button_pressed():
	
	if user_info.play_free != 0:
		$MainContainer/UIContainer/Buttons/LoaderMargin/LoadAnimation.visible = true
		$MainContainer/UIContainer/Buttons/LoaderMargin/LoadAnimation.play()
		$HTTPRequest.connect("request_completed", self, "on_POST_Start_request_completed")
		$HTTPRequest.POST_ScoreData(false, false)
		pass
	else:
		$PayOption.show()
		$PayOption/OptionContainer.show()
		$PayOption/CloseOptionButton.show()
		pass
	pass

func on_Guide_Button_pressed():
	
	var guide = guidePanel.instance()
	add_child(guide)

func on_Leaderboard_Button_pressed():
	
	var leaderboard = leaderboardPanel.instance()
	
	$HTTPRequest.connect("request_completed", self, "on_GET_Leaderboard_request_completed")
	$HTTPRequest.GET_LeaderboardData()
	
	add_child(leaderboard)
	closeLeaderboard = leaderboard.find_node("CloseButton")
	closeLeaderboard.disabled = true
	
	yield($HTTPRequest, "request_completed")
	
	$HTTPRequest.GET_UserRankData()
	$HTTPRequest.connect("request_completed", self, "on_GET_Rank_request_completed")

func on_TnC_Button_pressed():
	
	var tnc = tncPanel.instance()
	add_child(tnc)




func on_CloseOptionButton_pressed():
	
	$PayOption.hide()
	$PayOption/OptionContainer.hide()
	$PayOption/CloseOptionButton.hide()
	pass # Replace with function body.

func on_PoinButton_pressed():
	
	if int(user_info.poin_remaining) < 10:
		showWarning("res://assets/menu/DM_PW.png")
	else:
		$PayOption/ConfirmationPanel.show()
	pass

func on_AdButton_pressed():
	
	$PayOption/LoadingPanel.show()
	var adURL = "https://games-dev.macroad.co.id/ads?session="+$HTTPRequest.getSession()+"&platform_token="+globalVariables.game_data.game_token+"&email="+user_info.user_email+"&dob="+user_info.user_birthdate+"&gender="+user_info.user_gender+"&phone_number="+user_info.user_phone+""
	JavaScript.eval('window.location.replace('+'"'+adURL+'"'+')')
	
	pass # Replace with function body.

func on_CloseButton_pressed():
	
	$WarningPanel.hide()
	pass # Replace with function body.

func on_AgreeButton_pressed():
	
	$HTTPRequest.connect("request_completed", self, "on_POST_Start_request_completed")
	$HTTPRequest.POST_ScoreData(true, false)
	pass # Replace with function body.

func on_DisagreeButton_pressed():
	
	$PayOption/ConfirmationPanel.hide()
	pass # Replace with function body.



func on_GET_Validity_request_completed(_result, _response_code, _headers, body):
	
	var res = JSON.parse(body.get_string_from_utf8())
	var data = res.result
	
#	print(_response_code)
	if _response_code == 200:
		
		isAdValid = true
		pass
	elif _response_code == 400:
		
		isAdValid = false
		pass
	
	$HTTPRequest.disconnect("request_completed", self, "on_GET_Validity_request_completed")
	pass

func on_GET_Info_request_completed(_result, _response_code, _headers, body):
	
	var res = JSON.parse(body.get_string_from_utf8())
	var data = res.result
	
	if _response_code == 200:
		
		var gender
		
		if data.result.gender == "m":
			gender = "male"
		else:
			gender = "female"
		
		user_info = {
			"status_block": data.result.blocked,
			"status_email": data.result.isEmailVerif,
			"status_limit": data.result.isLimit,
			"user_email": data.result.email,
			"user_birthdate": data.result.dob,
			"user_gender": gender,
			"user_phone": "0" + data.result.phone_number.substr(3),
			"poin_remaining": data.result.userPoin,
			"play_free": data.result.lifePlay,
			"play_today": data.result.play_count,
			"ad_token": null,
			"score_last": data.result.lastScore,
			"score_game": data.result.gamePoin
		}
		
		$HTTPRequest.disconnect("request_completed", self, "on_GET_Info_request_completed")
	else :
		showWarning("res://assets/menu/WM_SE.png")
		pass

func on_POST_Start_request_completed(_result, _response_code, _headers, body):
	
	var res = JSON.parse(body.get_string_from_utf8())
	var data = res.result
	
	if _response_code == 200 :
		
		globalVariables.user_data.id = data.result.id
		
		if(globalVariables.user_data.id != null):
			
			$MainContainer/UIContainer/Buttons/LoaderMargin/LoadAnimation.visible = false
			$MainContainer/UIContainer/Buttons/LoaderMargin/LoadAnimation.stop()
			
			get_tree().change_scene("res://main scene/[R] Game.tscn")
			pass
		$HTTPRequest.disconnect("request_completed", self, "on_POST_Start_request_completed")
		pass
	else :
		if _response_code == 400:
			if data.result.code == "LP002":
				showWarning("res://assets/menu/DM_PW.png")
		#showWarning("res://assets/menu/WM_SE.png")
		pass
	
	pass

func on_GET_Leaderboard_request_completed(_result, _response_code, _headers, body):
	
	var res = JSON.parse(body.get_string_from_utf8())
	var data = res.result
	
	var panel = get_node("Leaderboard Panel")
	var highScoreBox = panel.find_node("HighScoreBox")
	var totalScoreBox = panel.find_node("CumulativeBox")
	
	if (_response_code == 200) :
		
		var highScoreUserData
		var totalScoreUserData
		var highScoreArray = []
		var totalScoreArray = []
		
		for i in range(5):
		
			highScoreUserData = preload("res://object scene/menu/User Score.tscn").instance()
			
			highScoreBox.add_child(highScoreUserData)
			highScoreArray.append(highScoreUserData)
		
		for i in range(5):
			
			totalScoreUserData = preload("res://object scene/menu/User Score.tscn").instance()
			
			totalScoreBox.add_child(totalScoreUserData)
			totalScoreArray.append(totalScoreUserData)
		
		for i in range(data.result.highscore_leaderboard.size()):
			
			if data.result.highscore_leaderboard[i]["user.name"] == null:
				highScoreArray[i].find_node("Name").text = "Anonymous"
			else:
				highScoreArray[i].find_node("Name").text = data.result.highscore_leaderboard[i]["user.name"]
			
			highScoreArray[i].find_node("Score").text = str(data.result.highscore_leaderboard[i].user_highscore)
		
		for i in range(data.result.totalscore_leaderboard.size()):
			
			if (data.result.totalscore_leaderboard[i]["user.name"] == null):
				totalScoreUserData[i].find_node("Name").text = "Anonymous"
			else:
				totalScoreUserData[i].find_node("Name").text = data.result.totalscore_leaderboard[i]["user.name"]
			
			totalScoreUserData[i].find_node("Score").text = str(data.result.totalscore_leaderboard[i].total_score)
		
		$HTTPRequest.disconnect("request_completed", self, "on_GET_Leaderboard_request_completed")
		pass
	else :
		pass
	
	pass

func on_GET_Rank_request_completed(_result, _response_code, _headers, body):
	
	var res = JSON.parse(body.get_string_from_utf8())
	var data = res.result
	
	
	if (_response_code == 200) :
		
		var panel = get_node("Leaderboard Panel")
		var rankBox = panel.find_node("RankBox")
		
		var highScoreData = preload("res://object scene/menu/User Rank.tscn").instance()
		var totalScoreData = preload("res://object scene/menu/User Rank.tscn").instance()
		
		rankBox.add_child(highScoreData)
		rankBox.add_child(totalScoreData)
		
		if data.result.rank_high_score != null:
			highScoreData.find_node("Rank").text = "#" + str(data.result.rank_high_score.ranking)
			highScoreData.find_node("Score").text = str(data.result.rank_high_score.user_highscore)
			pass
		else:
			highScoreData.find_node("Rank").text = "-"
			highScoreData.find_node("Score").text = str(0)
			pass
		
		if data.result.rank_total_score != null:
			totalScoreData.find_node("Rank").text = "#" + str(data.result.rank_total_score.ranking)
			totalScoreData.find_node("Score").text = str(data.result.rank_total_score.total_score)
			pass
		else:
			totalScoreData.find_node("Rank").text = "-"
			totalScoreData.find_node("Score").text = str(0)
			pass
		
		$HTTPRequest.disconnect("request_completed", self, "on_GET_Rank_request_completed")
		closeLeaderboard.disabled = false
		pass
	else :
		pass
	pass # Replace with function body.


