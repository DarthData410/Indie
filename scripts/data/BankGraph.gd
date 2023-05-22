extends Line2D

var gvs = load("res://scripts/data/graphvalues.gd").new()

var GraphSize:Vector2 = Vector2(0,0)
var Values:Array = []
var min_value:float = 0 
var max_value:float = 0
var parent_position:Vector2 = Vector2(0,0)
var GraphPointBtns:Array = []

# possible derived, hard-coded for now:
var _v_min_x:int = 5
var _v_min_y:int = 185
var _v_max_x:int = 685
var _v_max_y:int = 5

func _valuesX() -> Array:
	# Step section (x):
	var step:float = 0
	var sx = self._v_min_x
	var ex = self._v_max_x
	step = ex-sx
	step = roundf(step / (self.Values.size()-1))
	var _vx:Array = []
	var i:int =  0
	while i < self.Values.size():
		_vx.append(self._v_min_x+(step*i))
		i += 1
	return _vx

func _valuesY() -> Array:
	# Point section (y):
	var pnt:float = 0
	var sy = self._v_min_y
	var ey = self._v_max_y
	pnt = sy-ey
	var pnt_spread = self.max_value - self.min_value
	pnt = pnt/pnt_spread
	var _vy:Array = []
	var c:int = 0
	while c < self.Values.size():
		_vy.append(self._v_min_y-snappedf((self.Values[c].value*pnt),0.01))
		c += 1
	return _vy

func create_graph():
	var _vx = self._valuesX()
	var _vy = self._valuesY()
	
	var tot:int = self.Values.size()
	var p:int = 0
	while p < tot:
		var v = Vector2(_vx[p],_vy[p])
		self.Values[p].position = v
		self.Values[p].mouse_vector = Vector2(self.parent_position.x+v.x,self.parent_position.y+v.y)
		add_point(v)
		p += 1

func clear_values():
	self.Values.clear()

func add_value(v:float):
	var ngv = gvs.graphValue.new(v,0,0)
	self.Values.append(ngv)
	if self.max_value < v:
		self.max_value = v
	if self.min_value > v:
		self.min_value = v
