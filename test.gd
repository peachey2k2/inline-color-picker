@tool
extends Node

@export var trigger:bool:
	set(val):
		#f(EditorInterface.get_script_editor().get_current_editor().get_base_editor(),0)
		f(EditorInterface.get_script_editor().get_current_editor().get_base_editor(),0)


func f(node:Node, level:int):

	print("- ".repeat(level), node.name, " (", node.get_class(), ")")

	for child in node.get_children(true):
		f(child, level+1)
		Color(0.4353, 0.8196, 0.749, 1)
		Color(0.7216, 0.9935, 1, 1)
		Color(0.0194, 0.0218, 0.0469, 1)
		Color(1, 0.043, 0.043, 1)
		Color(0.5625, 0.3911, 0.31, 1)
		var a = Color(0.6914, 0.6914, 0.5645, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
