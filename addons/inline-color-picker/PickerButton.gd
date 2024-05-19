@tool
extends Button

signal call_picker(button:Button)
var ipos:Vector2i

func _ready():
	pressed.connect(func(): call_picker.emit(self))
