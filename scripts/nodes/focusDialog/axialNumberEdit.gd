extends PanelContainer
class_name AxialNumberEdit

@onready var editor:Editor = get_node("/root/editor")

signal valueSet(value:C)

var newlyInteracted:bool = false

var value:C = C.ZERO
var bufferedSign:C = C.ONE # since -0 (and 0i and -0i) cant exist, activate it when the number is set
var purpose:NumberEdit.PURPOSE = NumberEdit.PURPOSE.AXIAL

var zeroIValid:bool = false # whether or not zeroI is a vaild state
var isZeroI:bool = false

func _ready() -> void:
	Explainer.addControl(self,ControlExplanation.new("Number Edit",{Explainer.ARROWS_UD:"±1","-":"×-1","I":"×i"}))

func _gui_input(event:InputEvent) -> void:
	if Editor.isLeftClick(event): editor.focusDialog.interact(self)

func setValue(_value:C, manual:bool=false) -> void:
	value = _value
	isZeroI = false
	if bufferedSign.neq(1) and value.neq(0):
		bufferedSign = C.ONE
	if bufferedSign.eq(-1): %drawText.text = "-0"
	elif bufferedSign.eq(0,1): %drawText.text = "0i"; isZeroI = zeroIValid
	elif bufferedSign.eq(0,-1): %drawText.text = "-0i"
	else: %drawText.text = str(value)
	if !manual: valueSet.emit(value)

func increment() -> void: setValue(value.plus(1))
func decrement() -> void: setValue(value.minus(1))

func deNew():
	newlyInteracted = false
	theme_type_variation = &"NumberEditPanelContainerSelected"

func receiveKey(key:InputEventKey):
	var number:int = -1
	match key.keycode:
		KEY_TAB: editor.focusDialog.tabbed(self)
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
		KEY_MINUS, KEY_KP_SUBTRACT:
			if value.eq(0): bufferedSign = bufferedSign.times(-1)
			setValue(value.times(-1))
		KEY_BACKSPACE:
			theme_type_variation = &"NumberEditPanelContainerSelected"
			if Input.is_key_pressed(KEY_CTRL) or newlyInteracted: setValue(C.ZERO)
			else:
				if (value.r.gt(-10) and value.r.lt(0)): bufferedSign = C.nONE
				elif (value.i.gt(0) and value.i.lt(10)): bufferedSign = C.I
				elif (value.i.gt(-10) and value.i.lt(0)): bufferedSign = C.nI
				if value.eq(0): bufferedSign = C.ONE
				setValue(C.new(value.divint(10)))
			deNew()
		KEY_I:
			if value.eq(0): bufferedSign = bufferedSign.times(C.new(0,-1 if Input.is_key_pressed(KEY_SHIFT) else 1))
			setValue(value.times(C.I))
		KEY_UP: increment(); deNew()
		KEY_DOWN: decrement(); deNew()
		KEY_LEFT, KEY_RIGHT: deNew()
		_: return false
	if number != -1:
		if newlyInteracted:
			bufferedSign = value.axis()
			if bufferedSign.eq(0): bufferedSign = C.ONE
			setValue(C.ZERO,true)
		deNew()
		if value.axis().eq(0): setValue(bufferedSign.times(number))
		else: setValue(value.times(10).plus(value.axis().times(bufferedSign).times(number)))
	return true

func setZeroI() -> void:
	bufferedSign = C.I
	setValue(C.ZERO, true)
