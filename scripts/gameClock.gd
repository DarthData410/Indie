# this file contains all the classes, and logic related to the game clock needs.
# specifically for speeds (1x,4x,8x, and 12x speed) and setting the real time
# to game time variables.

# NOTE: As of this version 1x real time of 500 ms = 1 day. This is the time base

enum timeMultiply {
	one = 1,
	two = 2,
	three = 3,
	four = 4
}

class GameClock:
	var _baseTime:int = 500 # 500 ms @ 1x = 1 GameDay
	var _multiplier:timeMultiply = timeMultiply.one
	var _gameDays:int = 1
	var _elaspedMS:int # ms of actual time elasped
	var _iterations:int
	var _current_game_timer_wait_percent:float = 1
	var _current_game_timer_wait:float = 0.5
	var _baseDay:float = 0.5 # representing 500 ms = 1 in-game day
	var _game_year_base:int = 2015 # starting in year 2015
	var _game_year_month:int = 1 # starting in month 1, of 2015
	var _game_year_month_day:int = 1 # starting on day 1, of month 1, of 2015
	var _game_year_add:int = 0 # holds years that pass
	var _monthCheck:int = 1
	func _init():
		pass
	func GetBaseDay() -> float:
		return _baseDay
	func CheckMonth() -> bool:
		var ret:bool = false
		self._monthCheck += 1
		if self._monthCheck > 30:
			ret = true
			self._monthCheck = 1
			self._game_year_month += 1
			if self._game_year_month > 12:
				self._game_year_month = 1
				self._game_year_add += 1
		self._game_year_month_day = self._monthCheck
		return ret
	func SetWaitTime(v:int):
		self._baseTime = v
	func GetWaitTime() -> int:
		return self._baseTime
	func SetElaspedMS():
		self._elaspedMS = self._baseTime * self._iterations
	func LoadElaspedMS(v:int):
		self._elaspedMS = v
	func SetGameDays(v:int):
		self._gameDays = v
	func GameDays() -> int:
		return self._gameDays
	func GameMonthDay() -> int:
		return self._game_year_month_day
	func GameMonth() -> int:
		return self._game_year_month
	func GameYear() -> int:
		var ret:int = self._game_year_base
		ret = self._game_year_base+self._game_year_add
		return ret 
	func SetMultiplier(v:timeMultiply = timeMultiply.one):
		self._multiplier = v
	func Multiplier() -> timeMultiply:
		return _multiplier
	func SetIterations(v:int):
		self._iterations = v
	func Iterations() -> int:
		return self._iterations
	func CalcGameDays():
		self._gameDays = (self._elaspedMS / self._baseTime)
	func SetGameTimerWait(v:float):
		self._current_game_timer_wait = v
	func GetGameTimerWait() -> float:
		return self._current_game_timer_wait
	func CalcMultiplyValues(value:float):
		var tm = timeMultiply
		var v
		if value == 1:
			v = tm.one
			self._current_game_timer_wait = 0.5
		elif value == 2:
			v = tm.two
			self._current_game_timer_wait = 0.25
		elif value == 3:
			v = tm.three
			self._current_game_timer_wait = 0.125
		elif value == 4:
			self._current_game_timer_wait = 0.0625
			v = tm.four
		self._multiplier = v
		self._current_game_timer_wait_percent = self._current_game_timer_wait/self._baseDay # base day of 500 ms
	func GetGameTimerWaitPercent() -> float:
		return self._current_game_timer_wait_percent
	
	func to_dict() -> Dictionary:
		var ret:Dictionary = {
			baseTime = self._baseTime,
			multiplier = self._multiplier,
			gameDays = self._gameDays,
			elaspedMS = self._elaspedMS,
			iterations = self._iterations,
			gameTimerWait = self._current_game_timer_wait,
			gameTimerWaitPer = self._current_game_timer_wait_percent,
			baseDay = self._baseDay,
			gameYearBase = self._game_year_base,
			gameYearMonth = self._game_year_month,
			gameYearMonthDay = self._game_year_month_day,
			gameYearAdd = self._game_year_add,
			monthCheck = self._monthCheck
		}
		return ret
	static func from_dict(d:Dictionary) -> GameClock:
		# function used to load from saved game data
		var ret:GameClock = GameClock.new()
		ret.SetGameTimerWait(d.gameTimerWait)
		ret.SetWaitTime(d.baseTime)
		ret.SetGameDays(d.gameDays)
		ret.SetIterations(d.iterations)
		ret.LoadElaspedMS(d.elaspedMS)
		# Setting all variables from saved game:
		ret._multiplier = d.multiplier
		ret._current_game_timer_wait_percent = d.gameTimerWaitPer
		ret._baseDay = d.baseDay
		ret._game_year_base = d.gameYearBase
		ret._game_year_month = d.gameYearMonth
		ret._game_year_month_day = d.gameYearMonthDay
		ret._game_year_add = d.gameYearAdd
		ret._monthCheck = d.monthCheck
		return ret
