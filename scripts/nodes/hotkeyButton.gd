extends Button
class_name HotkeyButton

const fTalk:FontVariation = preload("res://resources/fonts/fControls.tres")

@onready var editor:Editor = get_node("/root/editor")

@export var defaultHotkey:StringName
@export var pressedHotkey:StringName

func _ready() -> void:
	connect("toggled", queue_redraw.unbind(1))
	add_to_group(&"hotkeyButton")

func _draw() -> void:
	if disabled or editor.settingsOpen: return
	var strWidth:int = int(fTalk.get_string_size(getCurrentHotkey(),HORIZONTAL_ALIGNMENT_LEFT,-1,12).x)
	draw_string(fTalk,Vector2((size.x-strWidth)/2,size.y+12),getCurrentHotkey(),HORIZONTAL_ALIGNMENT_LEFT,-1,12)

func getCurrentHotkey() -> String:
	if button_pressed:
		if pressedHotkey: return Explainer.hotkeyMap(pressedHotkey)
		else: return ""
	if defaultHotkey: return Explainer.hotkeyMap(defaultHotkey)
	else: return ""
