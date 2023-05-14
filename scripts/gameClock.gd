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
	var _gameDays:int = 0
	var _elaspedMS:int # ms of actual time elasped
	var _iterations:int
	var _current_game_timer_wait_percent:float = 1
	var _current_game_timer_wait:float = 0.5
	func _init():
		pass
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
		return _gameDays
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
		self._current_game_timer_wait_percent = self._current_game_timer_wait/0.5 # base day of 500 ms
	func GetGameTimerWaitPercent() -> float:
		return self._current_game_timer_wait_percent
	
	func to_dict() -> Dictionary:
		var ret:Dictionary = {
			baseTime = self._baseTime,
			gameDays = self._gameDays,
			elaspedMS = self._elaspedMS,
			iterations = self._iterations,
			gameTimerWait = self._current_game_timer_wait
		}
		return ret
	static func from_dict(d:Dictionary) -> GameClock:
		# function used to load from saved game data
		var ret:GameClock
		ret.SetGameTimerWait(d.gameTimerWait)
		ret.SetWaitTime(d.baseTime)
		ret.SetGameDays(d.gameDays)
		ret.SetIterations(d.iterations)
		ret.LoadElaspedMS(d.elaspedMS)
		return ret
