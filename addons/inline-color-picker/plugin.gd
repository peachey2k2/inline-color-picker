@tool
extends EditorPlugin

const POOL_SIZE := 50
const UPDATE_INTERVAL := 0.2

const PICKER = preload("res://addons/inline-color-picker/Picker.tscn")
const PICKER_BUTTON = preload("res://addons/inline-color-picker/PickerButton.tscn")

var base_editor:CodeEdit = null
var editor_settings:EditorSettings
var button_pool:Array[Button] = []
var button_base:Node2D
var picker:CanvasLayer
var letter_dims:Vector2i

var regex:RegEx

func _enter_tree():
	EditorInterface.get_script_editor().editor_script_changed.connect(_on_script_changed)
	editor_settings = EditorInterface.get_editor_settings()
	editor_settings.settings_changed.connect(func():
		for s in editor_settings.get_changed_settings(): _setting_updated(s))
	for s in checked_settings:
		settings[s] = editor_settings.get(s)
	button_base = Node2D.new()
	for i in POOL_SIZE:
		var ins := PICKER_BUTTON.instantiate()
		ins.icon = ins.icon.duplicate(true)
		button_base.add_child(ins)
		ins.call_picker.connect(call_picker)
	
	regex = RegEx.new()
	regex.compile("Color\\((?<c>.*)\\)")
		
	picker = PICKER.instantiate()
	await picker.ready
	picker.base.color_changed.connect(_picker_color_changed)
	picker.closed.connect(func(): timer.paused = false)
	
	_on_script_changed(null)

func _disable_plugin():
	EditorInterface.get_script_editor().editor_script_changed.disconnect(_on_script_changed)
	button_base.queue_free()
	picker.queue_free()

var settings := {}
var checked_settings:Array[String]= [
	"interface/editor/code_font_size",
	"text_editor/appearance/whitespace/line_spacing",
	"text_editor/behavior/indent/size",
]
func _setting_updated(setting:String):
	if not checked_settings.has(setting): return
	settings[setting.get_slice("/", setting.get_slice_count("/")-1)] = editor_settings.get(setting)

var last_scroll := Vector2.ZERO
func _on_scroll_updated(scroll:Vector2):
	button_base.position -= scroll - last_scroll
	last_scroll = scroll

var timer:Timer
func _on_script_changed(_scr:Script):
	var scr_editor := EditorInterface.get_script_editor().get_current_editor().get_base_editor() #
	if not scr_editor is CodeEdit: return

	base_editor = scr_editor
	base_editor.get_h_scroll_bar().value_changed.connect(func(v):_on_scroll_updated(Vector2(v*1,last_scroll.y)))
	base_editor.get_v_scroll_bar().value_changed.connect(func(v):_on_scroll_updated(Vector2(last_scroll.x,v*letter_dims.y)))
	
	if button_base.is_inside_tree():
		button_base.get_parent().remove_child(button_base)
	base_editor.add_child(button_base, false, Node.INTERNAL_MODE_BACK)
	base_editor.move_child(button_base, 0)
	
	if picker.is_inside_tree():
		picker.get_parent().remove_child(picker)
	base_editor.add_child(picker)
	picker.hide()
	
	update_positions()
	if is_instance_valid(timer):
		timer.queue_free()
	timer = Timer.new()
	base_editor.add_child(timer)
	timer.one_shot = false
	timer.start(UPDATE_INTERVAL)
	timer.timeout.connect(update_positions)

func update_positions():
	var first := Vector2i(-1, -1)
	var last := Vector2i.ZERO
	var idx := 0
	button_base.position = Vector2.ZERO
	
	while idx < POOL_SIZE:
		last = base_editor.search("Color(", CodeEdit.SEARCH_MATCH_CASE, last.y, last.x+1)
		if last.x < 0 or last == first: break
		
		var rect := base_editor.get_rect_at_line_column(last.y, last.x+1)
		var pos := rect.position
		if first.x < 0:
			first = last
			letter_dims = rect.size
		if pos.x < 0: continue
		
		var text := base_editor.get_line(last.y)
		var res := regex.search(text, last.x)
		if res == null: continue
		var color_str := res.get_string("c")
		pos.x += (color_str.length() + 8) * (letter_dims.x + 0.5) # no idk why it needs an extra 0.5 ass pull
		
		var split := color_str.split(",")
		var color := Color.WHITE
		var flag := false
		if split.size() > 4: continue
		if split.size() > 1: 
			for i in split.size():
				var s := split[i]
				s = s.strip_edges()
				if not s.is_valid_float():
					flag = true
					break
				color[i] = s.to_float()
		if flag: continue
		
		var button:Button = button_base.get_child(idx)
		button.show()
		button.position = pos
		button.ipos = last
		button.sel_end = last.x+color_str.length()+7
		button.color = color
		#base_editor.select(last.y, last.x+6, last.y, last.x+color_str.length()+7)
		
		idx += 1
	
	for i in range(idx, POOL_SIZE):
		button_base.get_child(i).hide()

func call_picker(button:Button):
	var editor_size := EditorInterface.get_base_control().size
	picker.base.color = button.color
	picker.panel.position = Vector2(
		min(button.global_position.x, editor_size.x - picker.panel.size.x),
		min(button.global_position.y, editor_size.y - picker.panel.size.y)
	)
	picker.panel.grab_focus()
	picker.show()
	base_editor.select(button.ipos.y, button.sel_end, button.ipos.y, button.ipos.x+5)
	timer.paused = true

func _picker_color_changed(col:Color):
	var cx := base_editor.get_caret_column()
	var cy := base_editor.get_caret_line()
	var s := str(col)
	base_editor.insert_text_at_caret(s)
	base_editor.select(cy, cx+s.length()+5, cy, cx)

