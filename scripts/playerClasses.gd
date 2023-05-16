# This file contains the main player classes used to support game play (basically game engine)
# Starting playerData, with initial phaseXP levels 10, increases by

enum phasePoints {
	Basic = 25,
	Exp = 30,
	Pro = 35,
	Elite = 40,
	Pioneer = 40
}

enum PhasePossiblePoints {
	design = 40,
	development = 40,
	testing = 30
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
				XP = 10
			},
			Fantasy = {
				level = 1,
				XP = 10
			},
			Sports = {
				level = 1,
				XP = 10
			},
			Racing = {
				level = 1,
				XP = 10
			}
		},
		genres = {
			Action = {
				level = 1,
				XP = 10
			},
			Adventure = {
				level = 1,
				XP = 10
			},
			Platformer = {
				level = 1,
				XP = 10
			}
		},
		platforms = {
			Mindows = {
				level = 1,
				XP = 10
			},
			PearOS = {
				level = 1,
				XP = 10
			},
			Linx = {
				level = 1,
				XP = 10
			}
		},
		audiences = {
			Everyone = {
				level = 1,
				XP = 10
			}
		},
		styles = {
			TwoD = {
				level = 1,
				XP = 10,
				label = "2d"
			}
		},
		sizes = {
			FirstGame = {
				level = 1,
				XP = 10
			}
		},
		publishing = {
			PaidFor = {
				level = 1,
				XP = 10,
				label = "Paid For"
			},
			FreeInGameAds = {
				level = 1,
				XP = 10,
				label = "Free|In-Game Ads"
			}
		}
	},
	game_id = 0,
	game_diffuclty = 0 # Effect $, ratings, bugs, etc. 
}

# Initialized New Game playerGameRatings Dictionary:
var playerGameRatings:Dictionary = {
	Ratings = []
}

# Initialized phaseXPused for a new game, that is developed:
var gamePhaseXPUsed:Dictionary = {
	design = 0,
	development = 0,
	testing = 0
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
	var key:String # OS.get_unique_id() | String
	var title:String
	var topic:String
	var genre:String
	var style:String
	var size:String
	var audience:String
	var platform:String
	var price:float
	var phaseXPused:Dictionary # Actual values selected by user for: design, dev, testing
	var gameSales:Array # Used with Game Sales Event
	var gameSalesDays:int # Starting with 0, # of days game on market for sale
	var publishing:Dictionary # Entry from playerData.RD.publishing node.
	# variables for in-game settings, XP, calculations, etc:
	var phaseXP:Dictionary
	# game sys variables:
	var game_id:int
	var created_date:String
	func _init(title,topic,genre,style,size,audience,platform,game_id):
		self.key = OS.get_unique_id()
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
		self.gameSalesDays = 0
	func get_key() -> String:
		return self.key
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
	func calc_gameSalesTot() -> float:
		var ret:float = 0
		for a in self.gameSales:
			ret += a[2]
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
			phasexpused = self.phaseXPused,
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
		ret.phaseXPused = d.phasexpused
		return ret
	static func get_playerGamesDict(v:Array) -> Dictionary:
		var playerGamesDict:Dictionary
		var i:int = 0
		for g in v:
			playerGamesDict.keys().append(i)
			playerGamesDict[i] = g.to_dict()
			i+=1
		return playerGamesDict
		

class playerResearch:
	var playerData:Dictionary
	func _init(d:Dictionary):
		self.playerData = d
	func _calcTopics():
		var xp:int=0
		var lvl:int=1
		for k in self.playerData.RD.topics.keys():
			xp = int(self.playerData.RD.topics[k]["XP"])
			if xp >= 20 and xp < 50:
				lvl = 2
			elif xp >= 50 and xp < 80:
				lvl = 3
			elif xp >= 80 and xp < 120:
				lvl = 4
			elif xp >= 120 and xp < 170:
				lvl = 5
			elif xp >= 170:
				lvl = 6
			else:
				lvl = 1
			self.playerData.RD.topics[k]["level"] = lvl
	func calcResearch(d:Dictionary):
		self.playerData = d
		self._calcTopics()

enum gameEvents {
	DEBUG = 0,
	GameSales = 1,
	GameRating = 2
}

class gameEvent:
	var Event:gameEvents
	var EventArray:Array # Should be recorded as part of game data.
	var GameKey:String
	var GameDay:int
	func _init(gkey:String,ea:Array,gd:int,ge:gameEvents=gameEvents.DEBUG):
		self.GameKey=gkey
		self.EventArray = ea
		self.Event = ge
		self.GameDay = gd
	func calcValue(x:float,y:float) -> float:
		var ret:float = 0.0
		ret = x*y
		return ret

class GameRatingAgent:
	var Rate:float = 0
	func _init(base:float,bump:float=0,agent:String="Indie.GameReviews"):
		if agent == "Indie.GameReviews":
			self.Rate = base*randf_range(1.01,1.09)
		elif agent == "Gamer.Weekly":
			self.Rate = base*randf_range(0.89,1.05)
		elif agent == "Games.What":
			self.Rate = base*randf_range(0.95,1.15)
		self.Rate = self.Rate+bump
	

class GameRatingsEvent extends gameEvent:
	var Agent:String
	var go:playerGameClass
	var RD:Dictionary
	var weighted:float
	var factor:float
	func _init(gkey:String,ea:Array,gd:int,g:playerGameClass,rd:Dictionary,w:float=1,f:float=0,gra:String="Indie.GameReviews"):
		self.Agent = gra
		self.go = g
		self.RD = rd
		self.weighted = w
		self.factor = f
		super._init(gkey,ea,gd,gameEvents.GameRating)
	func _calcRD() -> float:
		var ret:float = 0 # NOTE: /100 to equate each to a 0.x value, the threshold based rating effect
		var topic = self.RD.topics[self.go.topic]["level"] # Level first
		topic = topic * (float(self.RD.topics[self.go.topic]["XP"])/100) # XP
		var genre = self.RD.genres[self.go.genre]["level"] # Level first
		genre = genre * (float(self.RD.genres[self.go.genre]["XP"])/100) # XP
		var platform = self.RD.platforms[self.go.platform]["level"] # Level first
		platform = platform * (float(self.RD.platforms[self.go.platform]["XP"])/100) # XP
		var audience = self.RD.audiences[self.go.audience]["level"] # Level first
		audience = audience * (float(self.RD.audiences[self.go.audience]["XP"])/100) # XP
		ret = (topic+genre+platform+audience)/4
		return ret
	func _calcPhases() -> float:
		var ret:float = 0
		var design:float = float(self.go.phaseXPused["design"]) / PhasePossiblePoints.design
		var dev:float = float(self.go.phaseXPused["development"]) / PhasePossiblePoints.development
		var test:float = float(self.go.phaseXPused["testing"]) / PhasePossiblePoints.testing
		ret = (design + dev + test) / 3
		return ret
	func _calcWeighted(p:float) -> float:
		var ret:float = 0
		ret = (p*self.weighted)+self.factor
		return ret
	func _calcBump() -> float:
		var ret:float = 0
		if self.go.size == "FirstGame":
			ret = randf_range(0.85,1.05)
		return ret
	func _calcRate(p:float,rd:float) -> float:
		var ret:float = 0
		var GameRateAgent:GameRatingAgent = GameRatingAgent.new(p,self._calcBump(),self.Agent)
		ret = ((p*3)+GameRateAgent.Rate+rd)/5
		ret = self._calcWeighted(ret)
		return ret
	func calcValue(x:float,y:float) -> float:
		var ret:float = super.calcValue(x,y) # x,y can influence the scoring
		ret = ((self._calcRate(self._calcPhases(),self._calcRD())) * ret) * 10 # 1-10 scoring
		ret = roundf(ret)
		var ra:Array
		ra = [[self.GameKey,self.GameDay,ret,self.Agent]]
		self.EventArray.append_array(ra)
		return ret

class GameSalesEvent extends gameEvent:
	var GamePrice:float
	func _init(gkey:String,ea:Array,gd:int,gp:float):
		self.GamePrice = gp
		super._init(gkey,ea,gd,gameEvents.GameSales)
	func calcValue(x:float,y:float) -> float:
		var ret:float = super.calcValue(x,y)
		ret = (ret*self.GamePrice)
		var dsr:Array
		dsr = [[self.GameKey,self.GameDay,ret]]
		self.EventArray.append_array(dsr)
		return ret


