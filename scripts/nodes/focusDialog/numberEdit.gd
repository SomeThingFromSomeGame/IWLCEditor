extends PanelContainer
class_name NumberEdit

enum PURPOSE {SINGLE, SINGLE_NONNEGATIVE, REAL, IMAGINARY, AXIAL}

@onready var editor:Editor = get_node("/root/editor")

signal valueSet(value:PackedInt64Array)

var context:Node

var newlyInteracted:bool = false

var value:PackedInt64Array = M.ZERO
var bufferedNegative:bool = false # since -0 cant exist, activate it when the number is set
@export var purpose:PURPOSE = PURPOSE.SINGLE

func _ready() -> void:
	Explainer.addControl(self,ControlExplanation.new("/ Number Edit("+Explainer.ARROWS_UD+"±1 [%s]×-1 [%s]×i) /", [&"numberNegate", &"numberTimesI"]))
	await editor.ready
	context = editor.focusDialog

func _gui_input(event:InputEvent) -> void:
	if Editor.isLeftClick(event): context.interact(self)

func setValue(_value:PackedInt64Array, manual:bool=false) -> void:
	value = _value
	if bufferedNegative and M.ex(value):
		bufferedNegative = false
	if bufferedNegative: %drawText.text = "-0"
	else: %drawText.text = M.str(value)
	if !manual: valueSet.emit(value)

func increment() -> void: setValue(M.add(value, M.ONE))
func decrement() -> void: setValue(M.sub(value, M.ONE))

func deNew():
	newlyInteracted = false
	theme_type_variation = &"NumberEditPanelContainerSelected"

func receiveKey(key:InputEventKey):
	var number:int = -1
	if Editor.eventIs(key, &"numberTimesI"):
		if get_parent() is ComplexNumberEdit: get_parent().rotate()
	elif Editor.eventIs(key, &"numberNegate") and purpose != PURPOSE.SINGLE_NONNEGATIVE:
		if M.nex(value): bufferedNegative = !bufferedNegative
		setValue(M.negate(value))
	else:
		match key.keycode:
			KEY_TAB: context.tabbed(self)
			KEY_EQUAL: if purpose not in [PURPOSE.SINGLE, PURPOSE.SINGLE_NONNEGATIVE] and Input.is_key_pressed(KEY_SHIFT):
				context.interact((get_parent().imaginaryEdit if purpose == PURPOSE.REAL else get_parent().realEdit))
			KEY_0, KEY_KP_0: number = 0
			KEY_1, KEY_KP_1: number = 1
			KEY_2, KEY_KP_2: number = 2
			KEY_3, KEY_KP_3: number = 3
			KEY_4, KEY_KP_4: number = 4
			KEY_5, KEY_KP_5: number = 5
			KEY_6, KEY_KP_6: number = 6
			KEY_7, KEY_KP_7: number = 7
			KEY_8, KEY_KP_8: number = 8
			KEY_9, KEY_KP_9: number = 9
			KEY_BACKSPACE:
				theme_type_variation = &"NumberEditPanelContainerSelected"
				if Input.is_key_pressed(KEY_CTRL) or newlyInteracted: setValue(M.ZERO)
				else:
					var negative:bool = M.negative(value)
					setValue(M.divide(value,M.N(10)))
					if M.nex(value): bufferedNegative = negative
				deNew()
			KEY_UP: increment(); deNew()
			KEY_DOWN: decrement(); deNew()
			KEY_LEFT, KEY_RIGHT: deNew()
			_: return false
	if number != -1:
		if newlyInteracted:
			if M.negative(value): bufferedNegative = true
			setValue(M.ZERO,true)
		deNew()
		if M.negative(value) != bufferedNegative: setValue(M.sub(M.times(value,M.N(10)), M.N(number)))
		else: setValue(M.add(M.times(value,M.N(10)), M.N(number)))
	return true
