extends Selector
class_name LockTypeSelector

const ICONS:Array[Texture2D] = [
	preload("res://assets/ui/focusDialog/lockType/normal.png"),
	preload("res://assets/ui/focusDialog/lockType/blank.png"),
	preload("res://assets/ui/focusDialog/lockType/blast.png"),
	preload("res://assets/ui/focusDialog/lockType/all.png"),
	preload("res://assets/ui/focusDialog/lockType/exact.png"),
]

func _ready() -> void:
	columns = Lock.TYPES
	options = range(Lock.TYPES)
	defaultValue = Lock.TYPE.NORMAL
	buttonType = LockTypeSelectorButton
	super()
	for button in buttons:
		var explanation:ControlExplanation = ControlExplanation.new()
		match button.value:
			Lock.TYPE.NORMAL: explanation.hotkeys["N"] = "Set normal lock type"
			Lock.TYPE.BLANK: explanation.hotkeys["B"] = "Set blank lock type"
			Lock.TYPE.BLAST: explanation.hotkeys["X"] = "Set blast lock type"
			Lock.TYPE.ALL: explanation.hotkeys["A"] = "Set all lock type"
			Lock.TYPE.EXACT: explanation.hotkeys["E"] = "Set exact lock type"
		Explainer.addControl(button,explanation)

func changedMods() -> void:
	var lockTypes:Array[Lock.TYPE] = Mods.lockTypes()
	for button in buttons: button.visible = false
	for lockType in lockTypes: buttons[lockType].visible = true
	columns = len(lockTypes)

class LockTypeSelectorButton extends SelectorButton:
	var drawMain:RID

	func _init(_value:Lock.TYPE, _selector:LockTypeSelector):
		custom_minimum_size = Vector2(16,16)
		z_index = 1
		super(_value, _selector)
		icon = ICONS[value]
