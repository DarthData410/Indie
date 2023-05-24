
class graphBar:
	var start:Vector2 = Vector2(0,0)
	var end:Vector2 = Vector2(0,0)
	var value:float = 0.0
	var container:CenterContainer # CenterContrainer that contains the Line2D object
	var line:Line2D # Line2D object created, and referenced in game
	var text:String = ""
	
class RevenueGraph:
	var bars:Array = [] # Array of graphBar objects
	var bufferobjs:Array = [] # Array of supporitng objects to be removed during graph redraw
	var min_value:float = 0.0
	var max_value:float = 0.0
	var floor:float = 0.0
	var celling:float = 0.0
	var zspan:float = 0.0
	var wspan:float = 0.0
	var pnt:float = 0.0
	var width:int = 20 # in px
	var color:Color = Color.CORNFLOWER_BLUE # Fight Club reference, has to be the default! ;-]* 
	var step:int = 25 # px for x factor step in generating graph bars
	var buffer:int = 5 # px for buffer
	var position:Vector2 = Vector2(0,0) # position vector for graphBar's
	func _init():
		pass
	func calc_value_y(v:float) -> float:
		var ret:float = 0.0
		self.zspan = self.floor - self.celling
		self.wspan = self.max_value - self.min_value
		self.pnt = snappedf((self.zspan/self.max_value),0.001)
		ret = v*self.pnt
		ret = self.floor - ret
		return snappedf(ret,0.01)
	func add_bar(v:graphBar):
		assert(typeof(v)==typeof(graphBar))
		self.bars.append(v)
	

