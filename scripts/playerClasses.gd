# This file contains the main player classes used to support game play (basically game engine)
# Starting playerData, with initial phaseXP levels 10, increases by

enum phasePoints {
	Basic = 25,
	Exp = 30,
	Pro = 35,
	Elite = 40,
	Pioneer = 40
}

var playerData : Dictionary = {
	company_name = "<company name here>",
	first_name = "<first name here>",
	last_name = "<last name here>",
	phaseXP = {
		design = 1,
		development = 1,
		testing = 1,
		publish = 1,
		support = 1,
		retire = 1
	},
	phasePoints = {
		design = 0,
		development = 0,
		testing = 0,
		publish = 0,
		support = 0,
		retire = 0	
	},
	RD = {
		topics = {
			Space = {
				level = 1,
				XP = 0
			},
			Fantasy = {
				level = 1,
				XP = 0
			},
			Sports = {
				level = 1,
				XP = 0
			},
			Racing = {
				level = 1,
				XP = 0
			}
		},
		genres = {
			Action = {
				level = 1,
				XP = 0
			},
			Adventure = {
				level = 1,
				XP = 0
			},
			Platformer = {
				level = 1,
				XP = 0
			}
		},
		platforms = {
			Mindows = {
				level = 1,
				XP = 0
			},
			PearOS = {
				level = 1,
				XP = 0
			},
			Linx = {
				level = 1,
				XP = 0
			}
		},
		audiences = {
			Everyone = {
				level = 1,
				XP = 0
			}
		},
		styles = {
			TwoD = {
				level = 1,
				XP = 0,
				label = "2d"
			}
		},
		sizes = {
			FirstGame = {
				level = 1,
				XP = 0
			}
		},
		publishing = {
			PaidFor = {
				level = 1,
				XP = 0,
				label = "Paid For"
			},
			FreeInGameAds = {
				level = 1,
				XP = 0,
				label = "Free|In-Game Ads"
			}
		}
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
	
class playerGameClass:
	var title:String
	var topic:String
	var genre:String
	var style:String
	var size:String
	var audience:String
	var platform:String
	var price:float
	var gameSales:Array # Used with Game Sales Event
	var publishing:Dictionary # Entry from playerData.RD.publishing node.
	# variables for in-game settings, XP, calculations, etc:
	var phaseXP:Dictionary
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
		
		# initialize player_phaseXP variables:
		self.phaseXP = {
			design = 1,
			development = 1,
			testing = 1,
			publish = 1,
			support = 1,
			retire = 1
		}
	func get_key() -> String:
		var ret:String = "GK:"
		ret = ret + "::" + self.title + "::" + self.topic + "::" + self.genre + "::" + self.platform
		return ret
	func get_str() -> String:
		var ret:String
		ret = self.title + "," + self.topic + "," + self.genre + "," + self.platform
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
	func calc_xpwait(d:Dictionary,day:float):
		for k in d.keys():
			var pp = d[k]
			match pp:
				1:
					# 1 xp = 1.25 day
					self.phaseXP[k] = (self.calc_sizemulti()*1.25)*day
				2:
					# 1 xp = 1.05 day
					self.phaseXP[k] = (self.calc_sizemulti()*1.05)*day
				3:
					# 1 xp = 0.95 day
					self.phaseXP[k] = (self.calc_sizemulti()*0.95)*day
				4:
					# 1 xp = 0.85 day
					self.phaseXP[k] = (self.calc_sizemulti()*0.85)*day
				5:
					# 1 xp = 0.65 day
					self.phaseXP[k] = (self.calc_sizemulti()*0.65)*day
	func calc_sizemulti() -> float:
		var ret:float = 0
		if self.size == "FirstGame":
			ret = 1
		elif self.size == "Small":
			ret = 1.5
		elif self.size == "Medium":
			ret = 2.5
		elif self.size == "Large":
			ret = 4.0
		elif self.size == "Studio":
			ret = 5.0
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
			price = self.price,
			gamesales = self.gameSales,
			publishing = self.publishing,
			phaseXP = self.phaseXP,
			game_id = self.game_id,
			created_date = self.created_date
		}
		return ret
	static func from_dict(d:Dictionary):
		var ret:playerGameClass
		ret = playerGameClass.new(d.title,d.topic,d.genre,d.style,d.size,d.audience,d.platform,d.game_id)
		ret.created_date = d.created_date
		ret.gameSales = d.gamesales
		return ret
	static func get_playerGamesDict(v:Array) -> Dictionary:
		var playerGamesDict:Dictionary
		var i:int = 0
		for g in v:
			playerGamesDict.keys().append(i)
			playerGamesDict[i] = g.to_dict()
			i+=1
		return playerGamesDict
		

enum gameEvents {
	DEBUG = 0,
	GameSales = 1
}

class gameEvent:
	var Event:gameEvents
	var EventArray:Array # Should be recorded as part of game data.
	var GameKey:String
	func _init(gkey:String,ea:Array,ge:gameEvents=gameEvents.DEBUG):
		self.GameKey=gkey
		self.EventArray = ea
		self.Event = ge
	func calcValue(x:float,y:float) -> float:
		var ret:float = 0.0
		ret = x*y
		return ret

class GameSalesEvent extends gameEvent:
	func _init(gkey:String,ea:Array):
		super._init(gkey,ea,gameEvents.GameSales)
	func calcValue(x:float,y:float) -> float:
		var ret:float = super.calcValue(x,y)
		var price:float = 9.99 #
		var game_days:int = 10 #
		ret = (ret*price)
		var dsr:Array
		dsr = [[self.GameKey,game_days,ret]]
		self.EventArray.append_array(dsr)
		return ret
	

