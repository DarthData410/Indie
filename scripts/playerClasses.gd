# This file contains the main player classes used to support game play 

class playerGameClass:
	var title:String
	var topic:String
	var genre:String
	var game_id:int
	var created_date:String
	func _init(title,topic,genre,game_id):
		self.title = title
		self.genre = genre
		self.topic = topic
		self.game_id = game_id
	func get_str() -> String:
		var ret:String
		ret = "Game: " + self.title + "," + self.topic + "," + self.genre
		return ret
	func set_datenow():
		var time_return = Time.get_date_string_from_system(true)
		self.created_date = time_return
	func to_dict() -> Dictionary:
		var ret:Dictionary = {
			title = self.title,
			topic = self.topic,
			genre = self.genre,
			game_id = self.game_id,
			created_date = self.created_date
		}
		return ret
	static func from_dict(d:Dictionary):
		var ret:playerGameClass
		ret = playerGameClass.new(d.title,d.topic,d.genre,d.game_id)
		ret.created_date = d.created_date
		return ret
		
		

