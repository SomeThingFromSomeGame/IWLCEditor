extends Control
class_name DoorDialog

@onready var editor:Editor = get_node("/root/editor")
@onready var main:FocusDialog = get_parent()

@onready var lockHandler:LockHandler = %lockHandler
@onready var doorsHandler:DoorsHandler = %doorsHandler

func focus(focused:GameObject, new:bool, dontRedirect:bool) -> void: # Door or RemoteLock
	if focused is Door:
		%door.visible = true
		%remoteLock.visible = false
		%doorTypes.get_child(focused.type).button_pressed = true
		%lockHandler.colorLink.visible = focused.type == Door.TYPE.SIMPLE
		%spend.queue_redraw()
		%lockConfigurationSelector.visible = main.componentFocused and focused.type != Door.TYPE.SIMPLE
		%doorColorSelector.visible = main.componentFocused or focused.type != Door.TYPE.GATE # a mod will probably add something so i wont turn off the menu completely
		%frozen.button_pressed = focused.frozen
		%crumbled.button_pressed = focused.crumbled
		%painted.button_pressed = focused.painted
		%realInfiniteCopy.button_pressed = focused.infCopies.r.eq(1)
		%imaginaryInfiniteCopy.button_pressed = focused.infCopies.i.eq(1)
		if !main.componentFocused:
			%lockSettings.visible = false
			%doorAxialNumberEdit.visible = false
			%doorAuraSettings.visible = focused.type != Door.TYPE.GATE
			%doorCopySettings.visible = focused.type != Door.TYPE.GATE
			%doorColorSelector.setSelect(focused.colorSpend)
			%doorCopiesEdit.setValue(focused.copies, true)
			%spend.button_pressed = true
			%blastLockSettings.visible = false
		if main.interacted and !main.interacted.is_visible_in_tree(): main.deinteract()
		if %doorCopySettings.visible:
			if !main.interacted: main.interact(%doorCopiesEdit.realEdit)
		elif %doorAxialNumberEdit.visible:
			if !main.interacted: main.interact(%doorAxialNumberEdit)
		else: main.deinteract()
		if new:
			%lockHandler.setup(focused)
			if focused.type == Door.TYPE.SIMPLE and !dontRedirect: main.focusComponent(focused.locks[0])
	elif focused is RemoteLock:
		%door.visible = false
		%remoteLock.visible = true
		%doorAuraSettings.visible = true
		%lockConfigurationSelector.visible = false
		%doorsHandler.setup(focused)
		focusComponent(focused, new)

func focusComponent(component:GameComponent, _new:bool) -> void: # Lock or RemoteLock
	%doorColorSelector.visible = true
	%doorColorSelector.setSelect(component.color)
	if component is Lock: %lockHandler.setSelect(component.index)
	%lockTypeSelector.setSelect(component.type)
	if component is Lock:
		%lockConfigurationSelector.visible = main.focused.type != Door.TYPE.SIMPLE
		%lockConfigurationSelector.setup(component)
	%lockSettings.visible = true
	
	%doorAxialNumberEdit.visible = component.type == Lock.TYPE.NORMAL or component.type == Lock.TYPE.EXACT
	%doorAxialNumberEdit.setValue(component.count, true)

	%doorCopySettings.visible = false
	if component is Lock: %doorAuraSettings.visible = false

	%blastLockSettings.visible = component.type in [Lock.TYPE.BLAST, Lock.TYPE.ALL]
	%blastLockSign.button_pressed = component.denominator.sign() < 0
	%blastLockAxis.button_pressed = component.denominator.isNonzeroImag()
	
	%partialBlastSettings.visible = Mods.active(&"C3")
	%isPartial.visible = Mods.active(&"C3")
	%isPartial.button_pressed = component.isPartial
	%partialDenominator.visible = component.isPartial
	%discreteBlastSettings.visible = !component.isPartial and component.type != Lock.TYPE.ALL
	%partialBlastNumeratorEdit.setValue(component.count, true)
	%partialBlastDenominatorEdit.setValue(component.denominator, true)

	if component is Lock: %lockHandler.redrawButton(component.index)
	%lockNegated.button_pressed = component.negated
	%lockArmament.button_pressed = component.armament
	if main.interacted and !main.interacted.is_visible_in_tree(): main.deinteract()
	if %doorAxialNumberEdit.visible:
		if !main.interacted: main.interact(%doorAxialNumberEdit)
	elif %partialBlastSettings.visible:
		if !main.interacted: main.interact(%partialBlastNumeratorEdit.realEdit)
	else: main.deinteract()

func receiveKey(event:InputEvent) -> bool:
	match event.keycode:
		KEY_N:
			if Input.is_key_pressed(KEY_SHIFT) and Mods.active(&"C1"): _lockNegatedSet(!%lockNegated.button_pressed)
			else: _lockTypeSelected(Lock.TYPE.NORMAL)
		KEY_B: _lockTypeSelected(Lock.TYPE.BLANK)
		KEY_X: _lockTypeSelected(Lock.TYPE.BLAST)
		KEY_A:
			if Input.is_key_pressed(KEY_SHIFT) and Mods.active(&"C5"): _lockArmamentSet(!%lockArmament.button_pressed)
			else: _lockTypeSelected(Lock.TYPE.ALL)
		KEY_E: if Mods.active(&"C3"): _lockTypeSelected(Lock.TYPE.EXACT)
		KEY_C:
			if main.componentFocused: editor.quickSet.startQuick(QuickSet.QUICK.COLOR, main.componentFocused)
			else: editor.quickSet.startQuick(QuickSet.QUICK.COLOR, main.focused)
		KEY_L: if Input.is_key_pressed(KEY_CTRL): main.focused.addLock()
		KEY_F: if main.focused is RemoteLock: %doorsHandler.addComponent()
		KEY_MINUS: if !main.interacted and main.componentFocused and main.componentFocused.type == Lock.TYPE.BLAST: _blastLockSignSet(!%blastLockSign.button_pressed)
		KEY_I: if !main.interacted and main.componentFocused and main.componentFocused.type == Lock.TYPE.BLAST: _blastLockAxisSet(!%blastLockAxis.button_pressed)
		KEY_DELETE:
			if main.componentFocused:
				main.focused.removeLock(main.componentFocused.index)
				if len(main.focused.locks) != 0: main.focusComponent(main.focused.locks[-1])
				else: main.focus(main.focused)
			else: Changes.addChange(Changes.DeleteComponentChange.new(editor.game,main.focused))
			Changes.bufferSave()
		KEY_TAB:
			assert(main.componentFocused) # should be handled by interact otherwise
			if Input.is_key_pressed(KEY_SHIFT):
				if main.componentFocused.index == 0: main.interactDoorLastEdit()
				else: main.interactLockLastEdit(main.componentFocused.index-1)
			else:
				if main.componentFocused.index == len(main.componentFocused.parent.locks)-1: main.interactDoorFirstEdit()
				else: main.interactLockFirstEdit(main.componentFocused.index+1)
		_: return false
	return true

func changedMods() -> void:
	%lockSettingsSep.visible = Mods.active(&"C1")
	%lockNegated.visible = Mods.active(&"C1")
	%lockArmament.visible = Mods.active(&"C5")
	%realInfiniteCopy.visible = Mods.active(&"InfCopies")
	%imaginaryInfiniteCopy.visible = Mods.active(&"InfCopies")
	if main.componentFocused and main.componentFocused.type in [Lock.TYPE.BLAST, Lock.TYPE.ALL]:
		main.focusComponent(main.componentFocused)

func _doorColorSelected(color:Game.COLOR) -> void:
	if main.focused is not Door and main.focused is not RemoteLock: return
	if main.focused is Door:
		if main.componentFocused:
			Changes.addChange(Changes.PropertyChange.new(editor.game,main.componentFocused,&"color",color))
		elif %lockHandler.colorLink.button_pressed and main.focused.type == Door.TYPE.SIMPLE:
			Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused.locks[0],&"color",color))
		if !main.componentFocused or (%lockHandler.colorLink.button_pressed and main.focused.type == Door.TYPE.SIMPLE):
			Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"colorSpend",color))
	elif main.focused is RemoteLock:
		Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"color",color))
	Changes.bufferSave()

func _doorCopiesSet(value:C) -> void:
	if main.focused is not Door: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"copies",value))
	Changes.bufferSave()

func _doorAxialNumberSet(value:C) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"count",value))
	Changes.bufferSave()

func _lockTypeSelected(type:Lock.TYPE) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"type",type))

func _doorTypeSelected(type:Door.TYPE) -> void:
	if main.focused is not Door: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"type",type))
	Changes.bufferSave()

func _spendSelected() -> void:
	main.defocusComponent()
	main.focus(main.focused)

func _lockConfigurationSelected(option:ConfigurationSelector.OPTION) -> void:
	if main.componentFocused is not Lock: return
	var lock:GameComponent = main.componentFocused
	match option:
		ConfigurationSelector.OPTION.SpecificA:
			var configuration:Array = lock.getAvailableConfigurations()[0]
			lock._comboDoorConfigurationChanged(configuration[0], configuration[1])
		ConfigurationSelector.OPTION.SpecificB:
			var configuration:Array = lock.getAvailableConfigurations()[1]
			lock._comboDoorConfigurationChanged(configuration[0], configuration[1])
		ConfigurationSelector.OPTION.AnyS: lock._comboDoorConfigurationChanged(Lock.SIZE_TYPE.AnyS)
		ConfigurationSelector.OPTION.AnyH: lock._comboDoorConfigurationChanged(Lock.SIZE_TYPE.AnyH)
		ConfigurationSelector.OPTION.AnyV: lock._comboDoorConfigurationChanged(Lock.SIZE_TYPE.AnyV)
		ConfigurationSelector.OPTION.AnyM: lock._comboDoorConfigurationChanged(Lock.SIZE_TYPE.AnyM)
		ConfigurationSelector.OPTION.AnyL: lock._comboDoorConfigurationChanged(Lock.SIZE_TYPE.AnyL)
		ConfigurationSelector.OPTION.AnyXL: lock._comboDoorConfigurationChanged(Lock.SIZE_TYPE.AnyXL)
	Changes.bufferSave()

func _frozenSet(value:bool) -> void:
	if main.focused is not Door and main.focused is not RemoteLock: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"frozen",value))
	Changes.bufferSave()

func _crumbledSet(value:bool) -> void:
	if main.focused is not Door and main.focused is not RemoteLock: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"crumbled",value))
	Changes.bufferSave()

func _paintedSet(value:bool) -> void:
	if main.focused is not Door and main.focused is not RemoteLock: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"painted",value))
	Changes.bufferSave()

func _lockNegatedSet(value:bool) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"negated",value))
	Changes.bufferSave()

func partialBlastNumeratorSet(value:C) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"count",value))
	Changes.bufferSave()

func partialBlastDenominatorSet(value:C) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"denominator",value))
	Changes.bufferSave()

func _isPartialSet(value:bool) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"isPartial",value))
	Changes.bufferSave()

func _blastLockSignSet(value:bool) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	if lock.denominator.sign() < 0 == value: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"count",lock.count.times(-1)))
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"denominator",lock.denominator.times(-1)))
	Changes.bufferSave()

func _blastLockAxisSet(value:bool) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	if lock.denominator.isNonzeroImag() == value: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"count",lock.count.times(C.I if value else C.nI)))
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"denominator",lock.denominator.times(C.I if value else C.nI)))
	Changes.bufferSave()

func _doorRealInfiniteSet(value:bool) -> void:
	if main.focused is not Door: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"infCopies",C.new(int(value), main.focused.infCopies.i)))
	Changes.bufferSave()

func _doorImaginaryInfiniteSet(value:bool) -> void:
	if main.focused is not Door: return
	Changes.addChange(Changes.PropertyChange.new(editor.game,main.focused,&"infCopies",C.new(main.focused.infCopies.r, int(value))))
	Changes.bufferSave()

func _lockArmamentSet(value:bool) -> void:
	if main.componentFocused is not Lock and main.focused is not RemoteLock: return
	var lock:GameComponent = main.componentFocused if main.componentFocused is Lock else main.focused
	Changes.addChange(Changes.PropertyChange.new(editor.game,lock,&"armament",value))
	Changes.bufferSave()
