# for containing the graphvalues class used for creating 
# and storing graph values, x, y positions on graph. 

class graphValue:
	var value:float
	var position:Vector2
	var mouse_vector:Vector2
	var mouse_radius:int=3 # default px value
	func _init(v:float,x:int,y:int):
		self.value = v
		self.position = Vector2(x,y)
	func collide(pos:Vector2) -> bool:
		var ret:bool = false
		if pos.x >= (self.mouse_vector.x-self.mouse_radius) and pos.x <= (self.mouse_vector.x+self.mouse_radius):
			ret = true
		if ret:
			if pos.y >= (self.mouse_vector.y-self.mouse_radius) and pos.y <= (self.mouse_vector.y+self.mouse_radius):
				ret = true
			else:
				ret = false
		return ret
	func valueMsg() -> String:
		var ret:String = str(self.value)
		return ret
		
