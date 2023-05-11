# This file contains the game save system, as a single class, housing all actual
# save and load logic for the game. 

class GameSave:
	var _root:Dictionary
	var _save_meta:Dictionary = {}
	var _player_data:Dictionary = {}
	var _game_data:Dictionary = {}
	var _misc:Dictionary = {}
	var _save_file:String
	func _init(sf:String="user://GameSave.save"):
		self._save_file = sf
	func Meta(v:Dictionary={}) -> Dictionary:
		if v!={}:
			self._save_meta = v
		return self._save_meta	
	func PlayerData(v:Dictionary={}) -> Dictionary:
		if v!={}:
			self._player_data = v
		return self._player_data
	func GameData(v:Dictionary={}) -> Dictionary:
		if v!={}:
			self._game_data = v
		return self._game_data
	func Misc(v:Dictionary={}) -> Dictionary:
		if v!={}:
			self._misc = v
		return self._misc
	func WriteSaveGame():
		var SaveGameDict:Dictionary = {
			meta = self._save_meta,
			playerdata = self._player_data,
			gamedata = self._game_data,
			misc = self._misc
		}
		self._root = SaveGameDict
		var gsd = FileAccess.open(self._save_file,FileAccess.WRITE)
		gsd.store_var(self._root,true)
	func LoadSavedGame():
		var gsd = FileAccess.open(self._save_file,FileAccess.READ)
		self._root = gsd.get_var(true)
		self.Misc(self._root.misc)
		self.GameData(self._root.gamedata)
		self.PlayerData(self._root.playerdata)
		self.Meta(self._root.meta)
