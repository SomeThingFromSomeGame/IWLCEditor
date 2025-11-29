extends RichTextLabel
class_name QuickSet

const COLORS:Array[String] = [
	"Q", "W", "E", "R", "T", "A", "S", "D", "F", "G", "Z", "X", "V", "B", "QW", "EQ", "RQ", "DQ", "FQ", "EW", "RW", "AW", "ER"
]

@onready var editor:Editor = get_node("/root/editor")

var component:GameComponent
var quickType:StringName
var input:String = ""

func startQuick(type:StringName, _component:GameComponent) -> void:
	quickType = type
	component = _component
	visible = true
	%explainText.visible = false
	input = ""
	updateText()

func receiveInput(event:InputEvent) -> void:
	if event.is_action_released(quickType): applyOrCancel()
	elif event is InputEventKey and event.is_pressed() and !event.echo:
		if event.keycode >= 32 and event.keycode < 128:
			input += char(event.unicode).to_upper()
			updateText()

func updateText() -> void:
	text = "Quickset "
	match quickType:
		&"quicksetColor": text += "Color: "
	text += input

func applyOrCancel() -> void:
	match quickType:
		&"quicksetColor":
			var sorted = input.split()
			sorted.sort()
			var found:int = COLORS.find("".join(sorted))
			if found in Mods.colors():
				match component.get_script():
					KeyBulk: editor.focusDialog.keyDialog._keyColorSelected(found)
					Door, Lock: editor.focusDialog.doorDialog._doorColorSelected(found)
					KeyCounterElement: editor.focusDialog.keyCounterDialog._keyCounterColorSelected(found)
	visible = false
	%explainText.visible = true
	quickType = &""
	component = null
