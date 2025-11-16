extends Selector
class_name KeyTypeSelector

const ICONS:Array[Texture2D] = [
	preload("res://assets/ui/focusDialog/keyType/normal.png"),
	preload("res://assets/ui/focusDialog/keyType/exact.png"),
	preload("res://assets/ui/focusDialog/keyType/star.png"),
	preload("res://assets/ui/focusDialog/keyType/unstar.png"),
	preload("res://assets/ui/focusDialog/keyType/rotor.png"),
	preload("res://assets/ui/focusDialog/keyType/curse.png"),
	preload("res://assets/ui/focusDialog/keyType/uncurse.png"),
]

func _ready() -> void:
	columns = KeyBulk.TYPES
	options = range(KeyBulk.TYPES)
	defaultValue = KeyBulk.TYPE.NORMAL
	buttonType = KeyTypeSelectorButton
	super()
	for button in buttons:
		var explanation:ControlExplanation = ControlExplanation.new()
		match button.value:
			KeyBulk.TYPE.NORMAL: explanation.hotkeys["N"] = "Set normal key type"
			KeyBulk.TYPE.EXACT: explanation.hotkeys["E"] = "Set exact key type"
			KeyBulk.TYPE.STAR, KeyBulk.TYPE.UNSTAR: explanation.hotkeys["S"] = "Toggle star key type"
			KeyBulk.TYPE.ROTOR: explanation.hotkeys["R"] = "Rotate signflip/rotor key type"
			KeyBulk.TYPE.CURSE, KeyBulk.TYPE.UNCURSE: explanation.hotkeys["U"] = "Toggle curse key type"
		Explainer.addControl(button,explanation)

func changedMods() -> void:
	var keyTypes:Array[KeyBulk.TYPE] = Mods.keyTypes()
	for button in buttons: button.visible = false
	for keyType in keyTypes: buttons[keyType].visible = true
	columns = len(keyTypes)

class KeyTypeSelectorButton extends SelectorButton:
	var drawMain:RID

	func _init(_value:KeyBulk.TYPE, _selector:KeyTypeSelector):
		custom_minimum_size = Vector2(16,16)
		z_index = 1
		super(_value, _selector)
		icon = ICONS[value]
