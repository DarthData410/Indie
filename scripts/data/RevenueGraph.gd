
class graphBar:
	var start:Vector2 = Vector2(0,0)
	var end:Vector2 = Vector2(0,0)
	var value:float = 0.0
	var container:CenterContainer # CenterContrainer that contains the Line2D object
	var line:Line2D # Line2D object created, and referenced in game
	var text:String = ""
	
class RevenueGraph:
	var bars:Array = [] # Array of graphBar objects
	var min_value:float = 0.0
	var max_value:float = 0.0
	var width:int = 20 # in px
	var color:Color = Color.CORNFLOWER_BLUE # Fight Club reference, has to be the default! ;-]* 
	var step:int = 25 # px for x factor step in generating graph bars
	var buffer:int = 5 # px for buffer
	var position:Vector2 = Vector2(0,0) # position vector for graphBar's
	func _init():
		pass
	func add_bar(v:graphBar):
		assert(typeof(v)==typeof(graphBar))
		self.bars.append(v)
		if v.value > self.max_value:
			self.max_value = v.value

