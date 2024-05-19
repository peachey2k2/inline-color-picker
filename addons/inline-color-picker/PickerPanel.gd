@tool
extends CanvasLayer

@onready var base = $Panel/ColorPicker
@onready var panel = $Panel

func _ready():
	panel.focus_exited.connect(hide)
	panel.gui_input.connect(func(e:InputEvent): if e.is_action_pressed("ui_cancel"): hide())
	
func _physics_process(delta):
	panel.size = base.size
