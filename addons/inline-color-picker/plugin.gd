#@tool
extends EditorPlugin

const POOL_SIZE := 50
const UPDATE_INTERVAL := 0.5
const PICKER_BUTTON = preload("res://addons/inline-color-picker/PickerButton.tscn")

var base_editor:CodeEdit = null
var editor_settings:EditorSettings
var button_pool:Array[Button] = []
var picker_base:Node2D
var picker:ColorPicker
#var frame_lock := false


func _enter_tree():#Color
	EditorInterface.get_script_editor().editor_script_changed.connect(_on_script_changed)
	editor_settings = EditorInterface.get_editor_settings()
	editor_settings.settings_changed.connect(func():
		for s in editor_settings.get_changed_settings(): _setting_updated(s))
	for s in checked_settings:
		settings[s] = editor_settings.get(s)
	picker_base = Node2D.new()
	for i in POOL_SIZE:
		picker_base.add_child(PICKER_BUTTON.instantiate())

var settings := {}
var checked_settings:Array[String]= [
	"interface/editor/code_font_size",
	"text_editor/appearance/whitespace/line_spacing",
	"text_editor/behavior/indent/size",
]
func _setting_updated(setting:String):
	if not checked_settings.has(setting): return
	settings[setting.get_slice("/", setting.get_slice_count("/")-1)] = editor_settings.get(setting)

#func _physics_process(delta):
	#frame_lock = false

#var last_scroll := Vector2.ZERO
#func _on_scroll_updated(scroll:Vector2):
	##print(pickers)
	#for picker in pickers:
		##print(picker.position)
		#picker.position -= scroll - last_scroll
	#last_scroll = scroll

var timer:Timer
func _on_script_changed(_scr:Script):
	var scr_editor := EditorInterface.get_script_editor().get_current_editor().get_base_editor() #
	if not scr_editor is CodeEdit: return
	#for picker in pickers:
		#picker.queue_free()
	#pickers.clear()
	base_editor = scr_editor
	#base_editor.get_h_scroll_bar().value_changed.connect(func(v):_on_scroll_updated(Vector2(v*1,last_scroll.y)))
	#base_editor.get_v_scroll_bar().value_changed.connect(func(v):_on_scroll_updated(Vector2(last_scroll.x,v*24)))
	if picker_base.is_inside_tree():
		picker_base.get_parent().remove_child(picker_base)
	base_editor.add_child(picker_base, false, Node.INTERNAL_MODE_BACK)
	base_editor.move_child(picker_base, 0)
	
	if is_instance_valid(timer):
		timer.queue_free()
	timer = Timer.new()
	timer.one_shot = false
	timer.start(UPDATE_INTERVAL)
	timer.timeout.connect(update_positions)

func update_positions():
	base_editor.text

#func move_picker(picker:ColorPickerButton, pos:Vector2i):
	#var real_pos := Vector2(base_editor.get_pos_at_line_column(pos.y, pos.x))
	#if real_pos.x == -1:
		#picker.hide()
		#return
	#else:
		#picker.show()
	#pos =  + real_pos + last_scroll - Vector2(70, base_editor.get_theme_font_size("font_size")+base_editor.get_theme_constant("line_spacing")+5)
	#picker.position = Vector2(
		#pos.x - base_editor.get_h_scroll_bar().value * 1.0 + 70,
		#pos.y - base_editor.get_v_scroll_bar().value * 24.0
	#)

func _disable_plugin():
	EditorInterface.get_script_editor().editor_script_changed.disconnect(_on_script_changed)
