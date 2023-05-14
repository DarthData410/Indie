# This file contains the main player classes used to support game play 

# Starting playerData, with initial phaseXP levels 10, increases by:
# Basic = Starting point = 1x 1 point = 1 day, out of 20 possible on each phase
# Basic -> Exp - 25 points used = 2x 1 point = 0.5 day, out of 25 possible on each phase 
# Exp -> Pro - 50 points used = 3x 1 point = 0.25 day, out of 30 possible on each phase
# Pro -> Elite - 100 points used = 4x 1 point = 0.125 day, out of 35 possible on each phase
# Elite -> Pioneer - 200 points used = 5x 1 point = 0.0625 day, out of 40 possible on each phase
# ~~~~~~~~~~
# Current version game size, will effect the time each XP point is spent over 
# a course of game days. 
# The base game day is that 500 ms @ 1x multiplier = 1 game day
# ~~~:
# FirstGame = x 0.75 (-)
# Small = x 1.0 (=)
# Medium = x 1.25 (+)
# Large = x 1.5 (++)
# Studio = x 2 (+++)
# ----------------------------------->

enum phasePoints {
	Basic = 20,
	Exp = 25,
	Pro = 30,
	Elite = 35,
	Pioneer = 40
}

var playerData : Dictionary = {
	company_name = "<company name here>",
	first_name = "<first name here>",
	last_name = "<last name here>",
	player_phaseXP = {
		design = 1,
		development = 1,
		testing = 1,
		publish = 1,
		remake = 1,
		retire = 1
	},
	game_id = 0,
	game_diffuclty = 0
}

func get_phasetot(xp:int) -> int:
	var ret:int = 0
	match xp:
		1: # Basic
			ret = phasePoints.Basic
		2: # Exp
			ret = phasePoints.Exp
		3: # Pro
			ret = phasePoints.Pro
		4: # Elite
			ret = phasePoints.Elite
		5: # Pioneer
			ret = phasePoints.Pioneer
	return ret

func get_phaseused(d:Dictionary) -> int:
	var ret:int = 0
	for k in d.keys():
		ret += int(d[k])
	return ret

func test_designphase(x,CDesignPhase:Dictionary) -> int:
	var ret:int = 0
	if x.name == "HSSlideGraphics":
		ret = x.value + CDesignPhase.UI + CDesignPhase.GamePlay + CDesignPhase.Audio 
	elif x.name == "HSlideUI":
		ret = x.value + + CDesignPhase.Graphics + CDesignPhase.GamePlay + CDesignPhase.Audio
	elif x.name == "HSldeGamePlay":
		ret = x.value + CDesignPhase.Graphics + CDesignPhase.UI + CDesignPhase.Audio
	elif x.name == "HSlideAudio":
		ret = x.value + + CDesignPhase.Graphics + CDesignPhase.UI + CDesignPhase.GamePlay
	return ret
	
class playerGameClass:
	var title:String
	var topic:String
	var genre:String
	var style:String
	var size:String
	var audience:String
	var platform:String
	# variables for in-game settings, XP, calculations, etc:
	var phaseXPWait:Dictionary
	# game sys variables:
	var game_id:int
	var created_date:String
	func _init(title,topic,genre,style,size,audience,platform,game_id):
		self.title = title
		self.genre = genre
		self.topic = topic
		self.style = style
		self.size = size
		self.audience = audience
		self.platform = platform
		self.game_id = game_id
		
		# initialize playerXP variables:
		self.phaseXPWait = {
			design = 1,
			development = 1,
			testing = 1,
			publish = 1,
			remake = 1,
			retire = 1
		}
		
	func get_str() -> String:
		var ret:String
		ret = "Game: " + self.title + "," + self.topic + "," + self.genre
		return ret
	func set_datenow():
		var time_return = Time.get_date_string_from_system(true)
		self.created_date = time_return
	func get_platform_spritetype() -> int:
		var ret:int 
		if self.platform == "Mindows" or self.platform == "PearOS" or self.platform == "Linx":
			ret = 0 # Desktop
		elif self.platform == "Online":
			ret = 1 # Web
		elif self.platform == "pOS" or self.platform == "cyborg":
			ret = 2 # Mobile
		elif self.platform == "YBox" or self.platform == "PlayTrain" or self.platform == "Ninrendo":
			ret = 3 # Game System
		return ret
	func calc_xpwait(d:Dictionary):
		for k in d.keys():
			var pp = d[k]
			match pp:
				1:
					# 1 xp = 1 day
					self.phaseXPWait[k] = (self.calc_sizemulti()*1)*0.5
				2:
					# 1 xp = 0.5 day
					self.phaseXPWait[k] = (self.calc_sizemulti()*0.5)*0.5
				3:
					# 1 xp = 0.25 day
					self.phaseXPWait[k] = (self.calc_sizemulti()*0.25)*0.5
				4:
					# 1 xp = 0.125 day
					self.phaseXPWait[k] = (self.calc_sizemulti()*0.125)*0.5
				5:
					# 1 xp = 0.0625 day
					self.phaseXPWait[k] = (self.calc_sizemulti()*0.0625)*0.5
	func calc_sizemulti() -> float:
		var ret:float = 0
		if self.size == "FirstGame":
			ret = 0.75
		elif self.size == "Small":
			ret = 1
		elif self.size == "Medium":
			ret = 1.25
		elif self.size == "Large":
			ret = 1.5
		elif self.size == "Studio":
			ret = 2
		return ret
	func to_dict() -> Dictionary:
		var ret:Dictionary = {
			title = self.title,
			topic = self.topic,
			genre = self.genre,
			style = self.style,
			size = self.size,
			audience = self.audience,
			platform = self.platform,
			game_id = self.game_id,
			created_date = self.created_date
		}
		return ret
	static func from_dict(d:Dictionary):
		var ret:playerGameClass
		ret = playerGameClass.new(d.title,d.topic,d.genre,d.style,d.size,d.audience,d.platform,d.game_id)
		ret.created_date = d.created_date
		return ret
	static func get_playerGamesDict(v:Array) -> Dictionary:
		var playerGamesDict:Dictionary
		var i:int = 0
		for g in v:
			playerGamesDict.keys().append(i)
			playerGamesDict[i] = g.to_dict()
			i+=1
		return playerGamesDict
		
		

