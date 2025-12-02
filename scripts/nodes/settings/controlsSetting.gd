extends Button
class_name ControlsSetting

@export var label:String
@export var action:StringName

var setting:bool = false
var event:InputEventKey
var default:InputEventKey

func _init() -> void:
	theme_type_variation = &"RadioButtonText"
	custom_minimum_size = Vector2(200,24)
	toggle_mode = true

func _ready() -> void:
	default = InputMap.action_get_events(action)[0]
	mouse_entered.connect(func(): if !setting: text = "(RMB to reset)")
	mouse_exited.connect(_cancelSet)

func setText() -> void:
	if setting: text = "(Unhover to cancel)"
	else: text = label + ": " + event.as_text_physical_keycode()

func _startSet() -> void:
	button_pressed = true
	setting = true
	setText()

func _cancelSet() -> void:
	button_pressed = false
	setting = false
	setText()

func _gui_input(_event:InputEvent) -> void:
	if _event is InputEventMouseButton and _event.pressed:
			if !setting:
				match _event.button_index:
					MOUSE_BUTTON_LEFT: _startSet()
					MOUSE_BUTTON_RIGHT:
						setEvent(default)
					_: return
			else: _cancelSet()
			get_viewport().set_input_as_handled()

func _input(_event:InputEvent) -> void:
	if !setting or _event is InputEventMouse or !_event.pressed: return
	_event.keycode = 0
	_event.unicode = 0
	_event.pressed = false
	setEvent(_event)
	get_viewport().set_input_as_handled()
	_cancelSet()

func setEvent(to:InputEventKey) -> void:
	event = to
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, to)
	setText()
