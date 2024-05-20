@tool
extends CanvasLayer

signal closed

@onready var base = $Panel/ColorPicker
@onready var panel = $Panel

func _ready():
	panel.focus_exited.connect(_close)
	panel.gui_input.connect(func(e:InputEvent): if e.is_action_pressed("ui_cancel"): _close())
	
func _physics_process(delta):
	panel.size = base.size

func _close():
	closed.emit()
	hide()
