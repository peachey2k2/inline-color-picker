@tool
extends Button

signal call_picker(button:Button)
var ipos:Vector2i
var sel_end:int

var color:Color:
	set(val): icon.gradient.colors[0] = val
	get(): return icon.gradient.colors[0]

func _ready():
	pressed.connect(func(): call_picker.emit(self))
