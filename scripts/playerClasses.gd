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
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			Fantasy = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			Sports = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			Racing = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			}
		},
		genres = {
			Action = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			Adventure = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			Platformer = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			}
		},
		platforms = {
			Mindows = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			PearOS = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			},
			Linx = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			}
		},
		audiences = {
			Everyone = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			}
		},
		styles = {
			TwoD = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				label = "2d",
				NextXP = 20
			}
		},
		sizes = {
			FirstGame = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				NextXP = 20
			}
		},
		publishing = {
			PaidFor = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				label = "Paid For",
				NextXP = 20
			},
			FreeInGameAds = {
				level = 1,
				PreviousXP = 0,
				XP = 0,
				label = "Free|In-Game Ads",
				NextXP = 20
			}
		},
		XPBank = {
			Balance = 10,
			Spent = 0
		}
	},
	Bank = {
		Balance = 10000.00,
		Debits = [],
		Credits = [["SBE_10000","starting balance entry",1,10000.00]]
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
		

class playerBank:
	var playerData:Dictionary
	var periods:Dictionary = {
		period1 = {
			value = 0,
			day_start = 0,
			day_end = 30
		},
		period2 = {
			value = 0,
			day_start = 31,
			day_end = 60
		},
		period3 = {
			value = 0,
			day_start = 61,
			day_end = 90
		},
		period4 = {
			value = 0,
			day_start = 91,
			day_end = 120
		},
		period5 = {
			value = 0,
			day_start = 121,
			day_end = 150
		},
		period6 = {
			value = 0,
			day_start = 151,
			day_end = 180
		},
		period7 = {
			value = 0,
			day_start = 181,
			day_end = 210
		},
		period8 = {
			value = 0,
			day_start = 211,
			day_end = 240
		},
		period9 = {
			value = 0,
			day_start = 241,
			day_end = 270
		},
		period10 = {
			value = 0,
			day_start = 271,
			day_end = 300
		},
		period11 = {
			value = 0,
			day_start = 301,
			day_end = 330
		},
		period12 = {
			value = 0,
			day_start = 331,
			day_end = 360
		}
	}
	func _init(d:Dictionary):
		self.playerData = d
	func _sumDebits() -> float:
		var ret:float = 0.0
		var debitsa:Array = self.playerData.Bank.Debits
		for de in debitsa:
			ret += float(de[3])
		return roundf(ret)
	func _sumCredits() -> float:
		var ret:float = 0.0
		var creditsa:Array = self.playerData.Bank.Credits
		for ce in creditsa:
			ret += float(ce[3])
		return roundf(ret)
	func _calcBalance():
		var currbal:float = float(self.playerData.Bank.Balance)
		var debits:float = self._sumDebits()
		var credits:float = self._sumCredits()
		var newbal:float = credits - debits
		self.playerData.Bank.Balance = roundf(newbal)
	func addEntry(type:String,name:String,day:int,value:float):
		var entrya:Array = self.playerData.Bank[type] #Expect type = Debits or Credits
		var dkey = OS.get_unique_id()
		var new_entry:Array = [[dkey,name,day,value]]
		entrya.append_array(new_entry)
		self.playerData.Bank[type] = entrya
		self._calcBalance()

class playerResearch:
	var playerData:Dictionary
	var newData:Array
	var updateData:Array
	var _toNxt:int = 0
	var _newXP:int = 0
	func _init(d:Dictionary):
		self.playerData = d
	func _calcBaseXP(xp,cl,cnxp,prevxp) -> int:
		var ret:int = 0
		var nxp:int = 0
		if cl == 1 and xp >= 20:
			ret = 2
			nxp = xp-20
			self._toNxt = 50 - nxp
			self._newXP = nxp
		elif cl == 2 and xp >= 50:
			ret = 3
			nxp = xp - 50
			self._toNxt = 80 - nxp
			self._newXP = nxp
		elif cl == 3 and xp >= 80:
			ret = 4
			nxp = xp - 80
			self._toNxt = 120 - nxp
			self._newXP = nxp
		elif cl == 4 and xp >= 120:
			ret = 5
			nxp = xp -120
			self._toNxt = 170 - nxp
			self._newXP = nxp
		elif (cl == 5 and xp >= 170) or cl == 6:
			ret = 6
			self._toNxt = 0
			self._newXP = xp
		# Final piece:
		if ret == 0:
			self._newXP = xp
			ret = cl
			self._toNxt = cnxp - (self._newXP - prevxp)
		return ret
	func _calcType(t:String,tv:String):
		var xp:int=0
		var lvl:int=1
		var cl:int=1
		var cnxp:int=0
		var prevxp:int=0
		var k = tv
		xp = int(self.playerData.RD[t][k]["XP"])
		cl = int(self.playerData.RD[t][k]["level"])
		cnxp = int(self.playerData.RD[t][k]["NextXP"])
		prevxp = int(self.playerData.RD[t][k]["PreviousXP"])
		lvl = self._calcBaseXP(xp,cl,cnxp,prevxp)
		self.playerData.RD[t][k]["level"] = lvl
		self.playerData.RD[t][k]["XP"] = self._newXP
		self.playerData.RD[t][k]["NextXP"] = self._toNxt
		self.playerData.RD[t][k]["PreviousXP"] = self._newXP
				
	func _checkType(t:String,v:String) -> bool:
		var ret:bool = true
		for k in self.playerData.RD[t].keys():
			if v == k:
				ret = false
				break
		return ret
	func _newType(t:String):
		var gdata = load("res://scripts/data/gamedata.gd").new()
		var ngdo:Dictionary = gdata.NewGameDataOptions
		var i:int = 0
		var a:Array
		for v in ngdo[t]:
			if self._checkType(t,v):
				a.append(v)
				i += 1
		var ri:int = randi_range(0,(i-1))
		var nt:String = a[ri]
		var RDt:Dictionary = self.playerData.RD[t]
		RDt.keys().append(nt)
		RDt[nt] = {
			level = 1,
			PreviousXP = 0,
			XP = 0,
			NextXP = 20
		}
		self.playerData.RD[t] = RDt
	func _updateXPBank(v:int):
		var RDB:Dictionary = self.playerData.RD.XPBank
		var b:int = int(RDB.Balance)
		b = b - v
		var s:int = int(RDB.Spent)
		s = s + v
		RDB.Balance = b
		RDB.Spent = s
		self.playerData.RD.XPBank = RDB
	func _updateType(t:String,tv:String,v:int):
		var RDt:Dictionary = self.playerData.RD[t]
		var cxp:int = int(RDt[tv]["XP"])
		cxp = cxp + v
		RDt[tv]["XP"] = cxp
		self.playerData.RD[t] = RDt
		self._updateXPBank(v)
	func _calcTypeUpdates(t:String,tv:String):
		self._calcType(t,tv)
	func addNewData(nt:String):
		self.newData.append(nt)
	func addUpdateData(upt:String,uptc:String,upv:int):
		var la:Array = [[upt,uptc,upv]]
		self.updateData.append_array(la)
	func calcResearch():
		# Update XPBank balance per spend direction:
		for v in self.newData:
			self._newType(v)
		for vu in self.updateData:
			self._updateType(vu[0],vu[1],vu[2])
			# Update Research Types for playerData:
			self._calcTypeUpdates(vu[0],vu[1])

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
		ret = roundf(ret*self.GamePrice)
		var dsr:Array
		dsr = [[self.GameKey,self.GameDay,ret]]
		self.EventArray.append_array(dsr)
		return ret


