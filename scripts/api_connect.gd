extends HTTPRequest

onready var AES_Encrypt = preload("res://scripts/AES.gd").new()

func GET_UserData():
	
	var data = {
		"lat": null,
		"long": null,
		"session": getSession(),
		"linigame_platform_token": globalVariables.game_data.game_token
	}
	var headers = [
		"Content-Type: application/json",
	]
	
	var body = JSON.print({
		"datas": encryptData(data)
	})
	
	var request = request(globalVariables.game_data.linigame_url + "api/v1.0/leaderboard/check_user_limit/", headers, true, HTTPClient.METHOD_POST, body)
	if request != OK:
		push_error("Error")
	pass

func GET_CheckAdValidity():
	
#	print(getAdID())
	
	var data = {
		"session": getSession(),
		"linigame_platform_token": globalVariables.game_data.game_token,
		"identifier": getAdID()
	}
	
	var headers = [
		"Content-Type: application/json",
	]
	
	var body = JSON.print(data)
	
	var request = request(globalVariables.game_data.linigame_url + "api/v1.0/leaderboard/check_ads/", headers, true, HTTPClient.METHOD_POST, body)
	if request != OK:
		push_error("Error")
	pass

func GET_LeaderboardData():
	
	var request = request(globalVariables.game_data.linigame_url + "api/v1.0/leaderboard/leaderboard_imlek?limit_highscore=5&limit_total_score=5&linigame_platform_token=" + globalVariables.game_data.game_token)
	if request != OK:
		push_error("Error")
	pass

func GET_UserRankData():
	
	var request = request(globalVariables.game_data.linigame_url + "api/v1.0/leaderboard/get_user_rank_imlek/?session=" + getSession() + "&limit=5&linigame_platform_token=" + globalVariables.game_data.game_token)
	if request != OK:
		push_error("Error")
	pass

func POST_ScoreData(paymentMethod, withAd):
	
	var body
	var requestID = encryptData("LG" + "+" + globalVariables.game_data.game_token + "+" + getDateNow())
	var data = {
		"score": 0,
		"user_highscore": 0,
		"total_score": 0,
		"game_start": getDate(),
		"session": getSession(),
		"linigame_platform_token": globalVariables.game_data.game_token,
	}
	
	var headers = [
		"Content-Type: application/json",
		"request-id: "+ requestID + ""
	]
	
	if paymentMethod == false:
		data.play_video = "not_played"
		
		body = JSON.print({
			"datas": encryptData(data)
		})
		pass
	else:
		if withAd == true:
			data.play_video = "full_played"
			body = JSON.print({
				"datas": encryptData(data)
			})
		else:
			data.play_video = "not_played"
			body = JSON.print({
				"datas": encryptData(data)
			})
		pass
	
	var request = request(globalVariables.game_data.linigame_url + "api/v1.0/leaderboard/dodge_the_creeps/", headers, true, HTTPClient.METHOD_POST, body)
	if request != OK:
		push_error("Error")
	pass

func GET_AdContent(email, dob, gender, phone):
	
	var request = request(globalVariables.game_data.captive_url + "api/v2/linigames/advertisement?email="+email+"&dob="+dob+"&gender="+gender+"&phone_number="+phone)
	if request != OK:
		push_error("Error")
	pass

func UPDATE_ScoreData(id, finalScore, dataLog):
	
	var body
	var requestID = encryptData("LG" + "+" + globalVariables.game_data.game_token + "+" + getDateNow())
	var data = {
		"id": id,
		"log": dataLog,
		"score": finalScore,
		"game_end": getDate(),
		"session": getSession(),
		"linigame_platform_token": globalVariables.game_data.game_token,
	}
	
	var headers = [
		"Content-Type: application/json",
		"request-id: "+ requestID + ""
	]
	
	body = JSON.print({
			"datas": encryptData(data)
	})
	
	var request = request(globalVariables.game_data.linigame_url + "api/v1.0/leaderboard/dodge_the_creeps/", headers, true, HTTPClient.METHOD_PUT, body)
	if request != OK:
		push_error("Error")
	
	pass

func getAdID():
	
	return JavaScript.eval("""
			var urlParams = new URL(window.location.href);
			var identifier = encodeURI(urlParams.searchParams.get('identifier'));

			identifier.replace(/%20/g, '+')
		""")

#	return "U2FsdGVkX1+r1bQzUd1K8bFlwnT9OFiAxBpeMAlXgzaLCse2JaAkiJn5ZPQsos6sjUkvMmmMJB2EBlI9IxUw/SV253uu6aqLKtWjkk9wEhhbNwNZ2mv1FridNUlc2bLz"
	pass

func getSession():
	
	return JavaScript.eval("""
			var urlParams = new URL(window.location.href);
			urlParams.searchParams.get('session');
		""")
	
#	return "489de55a30bba145fedfe7e558670dab8979fd73a4febd2b1c5c6770ef9e1f23"
	pass

func getDate():
	
#	var date = JavaScript.eval("let date = new Date();")
#	return date
	var time = OS.get_datetime()
	var nameweekday= ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	var namemonth= ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	var dayofweek = time["weekday"]   # from 0 to 6 --> Sunday to Saturday
	var day = time["day"]                         #   1-31
	var month= time["month"]               #   1-12
	var year= time["year"]             
	var hour= time["hour"]                     #   0-23
	var minute= time["minute"]             #   0-59
	var second= time["second"]             #   0-59

	return str(nameweekday[dayofweek]) + ", " + str("%02d" % [day]) + " " + str(namemonth[month-1]) + " " + str(year) + " " + str("%02d" % [hour]) + ":" + str("%02d" % [minute]) + ":" + str("%02d" % [second]) + " GMT"
	pass

func getDateNow():
	
	var js_date_now = JavaScript.eval("Date.now();")
	return str(js_date_now)
	
#	var dateTime = str(OS.get_unix_time_from_datetime(OS.get_datetime(true)))
#	var dateMilliSecond = str(OS.get_ticks_msec()).left(3)
#
#	return dateTime + "" + dateMilliSecond
	pass

func encryptData(data):
	
	var encrypt = AES_Encrypt.encrypt(JSON.print(data), "c0dif!#l1n!9am#enCr!pto9r4pH!*12", null, AES_Encrypt.PadType.PKCS7)
	
	return Marshalls.raw_to_base64(encrypt)


