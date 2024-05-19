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
		Color(1,1,1,1)
		Color(1,1,1,1)
		Color(1,1,1,1)
		Color(1,1,1,1)
		var a = Color(1,1,1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
