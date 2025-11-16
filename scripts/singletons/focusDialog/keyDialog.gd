extends Control
class_name KeyDialog

@onready var editor:Editor = get_node("/root/editor")
@onready var main:FocusDialog = get_parent()

const STAR_UN_ICONS:Array[Texture2D] = [ preload("res://assets/ui/focusDialog/keySplitType/star.png"), preload("res://assets/ui/focusDialog/keySplitType/unstar.png") ]
const CURSE_UN_ICONS:Array[Texture2D] = [ preload("res://assets/ui/focusDialog/keySplitType/curse.png"), preload("res://assets/ui/focusDialog/keySplitType/uncurse.png") ]

func focus(focused:KeyBulk,_new:bool) -> void:
	%keyColorSelector.setSelect(focused.color)
	%keyTypeSelector.setSelect(focused.type)
	%keyCountEdit.visible = focused.type in [KeyBulk.TYPE.NORMAL,KeyBulk.TYPE.EXACT]
	%keyCountEdit.setValue(focused.count, true)
	%keyInfiniteToggle.button_pressed = focused.infinite
	%keyRotorSelector.visible = focused.type == KeyBulk.TYPE.ROTOR
	%keyUn.visible = focused.type in [KeyBulk.TYPE.STAR, KeyBulk.TYPE.CURSE]
	%keyUn.button_pressed = !focused.un
	setKeyUnIcon()
	if focused.type == KeyBulk.TYPE.ROTOR: %keyRotorSelector.setValue(focused.count)
	if %keyCountEdit.visible:
		if !main.interacted: main.interact(%keyCountEdit.realEdit)
	else: main.deinteract()

func receiveKey(event:InputEventKey) -> bool:
	match event.keycode:
		KEY_N: _keyTypeSelected(KeyBulk.TYPE.NORMAL)
		KEY_E: _keyTypeSelected(KeyBulk.TYPE.EXACT if main.focused.type != KeyBulk.TYPE.EXACT else KeyBulk.TYPE.NORMAL)
		KEY_S:
			if main.focused.type == KeyBulk.TYPE.STAR: Changes.PropertyChange.new(main.focused,&"un",!main.focused.un)
			else: _keyTypeSelected(KeyBulk.TYPE.STAR)
		KEY_R:
			if main.focused.type != KeyBulk.TYPE.ROTOR: _keyTypeSelected(KeyBulk.TYPE.ROTOR)
			elif main.focused.count.eq(-1): _keyCountSet(C.I)
			elif main.focused.count.eq(C.I): _keyCountSet(C.nI)
			elif main.focused.count.eq(C.nI): _keyTypeSelected(KeyBulk.TYPE.NORMAL); _keyCountSet(C.ONE)
		KEY_C: editor.quickSet.startQuick(QuickSet.QUICK.COLOR, main.focused)
		KEY_U:
			if Mods.active(&"C5") and main.focused is KeyBulk:
				if main.focused.type == KeyBulk.TYPE.CURSE: Changes.PropertyChange.new(main.focused,&"un",!main.focused.un)
				else: _keyTypeSelected(KeyBulk.TYPE.CURSE)
		KEY_DELETE:
			Changes.addChange(Changes.DeleteComponentChange.new(main.focused))
			Changes.bufferSave()
		KEY_Y: _keyInfiniteToggled(!main.focused.infinite)
		_: return false
	return true

func _keyColorSelected(color:Game.COLOR) -> void:
	if main.focused is not KeyBulk: return
	Changes.addChange(Changes.PropertyChange.new(main.focused,&"color",color))
	Changes.bufferSave()

func _keyTypeSelected(type:KeyBulk.TYPE) -> void:
	if main.focused is not KeyBulk: return
	var beforeType:KeyBulk.TYPE = main.focused.type
	Changes.addChange(Changes.PropertyChange.new(main.focused,&"type",type))
	if beforeType != type and type == KeyBulk.TYPE.ROTOR: Changes.PropertyChange.new(main.focused,&"count",C.nONE)
	Changes.bufferSave()

func _keyCountSet(count:C) -> void:
	if main.focused is not KeyBulk: return
	Changes.addChange(Changes.PropertyChange.new(main.focused,&"count",count))
	Changes.bufferSave()

func _keyInfiniteToggled(value:bool) -> void:
	if main.focused is not KeyBulk: return
	Changes.addChange(Changes.PropertyChange.new(main.focused,&"infinite",value))
	Changes.bufferSave()

func _keyRotorSelected(value:KeyRotorSelector.VALUE):
	if main.focused is not KeyBulk: return
	match value:
		KeyRotorSelector.VALUE.SIGNFLIP: Changes.addChange(Changes.PropertyChange.new(main.focused,&"count",C.nONE))
		KeyRotorSelector.VALUE.POSROTOR: Changes.addChange(Changes.PropertyChange.new(main.focused,&"count",C.I))
		KeyRotorSelector.VALUE.NEGROTOR: Changes.addChange(Changes.PropertyChange.new(main.focused,&"count",C.nI))
	Changes.bufferSave()

func _keyUnToggled(value:bool):
	if main.focused is not KeyBulk: return
	Changes.addChange(Changes.PropertyChange.new(main.focused,&"un",!value))
	Changes.bufferSave()
	setKeyUnIcon()

func setKeyUnIcon() -> void:
	match main.focused.type:
		KeyBulk.TYPE.STAR: %keyUn.icon = STAR_UN_ICONS[int(main.focused.un)]
		KeyBulk.TYPE.CURSE: %keyUn.icon = CURSE_UN_ICONS[int(main.focused.un)]
