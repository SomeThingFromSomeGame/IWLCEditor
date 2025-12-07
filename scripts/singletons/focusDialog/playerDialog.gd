extends Control
class_name PlayerDialog

@onready var editor:Editor = get_node("/root/editor")
@onready var main:FocusDialog = get_parent()

var color:Game.COLOR

func focus(focused:GameObject, new:bool) -> void:
	%playerSpawnSettings.visible = focused is PlayerSpawn
	%playerSettings.visible = focused is PlayerPlaceholderObject or Game.levelStart != focused
	if new: setSelectedColor(Game.COLOR.WHITE)
	else: _playerColorSelected(color)
	if %playerSpawnSettings.visible:
		if Game.levelStart == focused: %levelStart.button_pressed = true
		else: %savestate.button_pressed = true
	if %playerSettings.visible:
		if !main.interacted: main.interact(%playerKeyCountEdit.realEdit)

func setSelectedColor(toColor:Game.COLOR) -> void:
	%playerColorSelector.setSelect(toColor)
	_playerColorSelected(toColor)

func _playerColorSelected(_color:Game.COLOR) -> void:
	color = _color
	if main.focused is PlayerPlaceholderObject:
		%playerKeyCountEdit.setValue(Game.player.key[color], true)
		%playerStar.button_pressed = Game.player.star[color]
		%playerCurse.button_pressed = Game.player.curse[color]
	else:
		%playerKeyCountEdit.setValue(main.focused.key[color], true)
		%playerStar.button_pressed = main.focused.star[color]
		%playerCurse.button_pressed = main.focused.curse[color]

func changedMods() -> void:
	%playerCurse.visible = Mods.active(&"C5")

func _playerKeyCountSet(value:PackedInt64Array) -> void:
	if main.focused is PlayerPlaceholderObject:
		Game.player.key[color] = value
		Game.player.checkKeys()
	else: Changes.addChange(Changes.ArrayElementChange.new(main.focused,&"key",color,value))

func _playerStarSet(toggled_on:bool) -> void:
	if main.focused is PlayerPlaceholderObject:
		Game.player.star[color] = toggled_on
	else: Changes.addChange(Changes.ArrayElementChange.new(main.focused,&"star",color,toggled_on))

func _playerCurseSet(toggled_on:bool) -> void:
	if main.focused is PlayerPlaceholderObject:
		Game.player.curse[color] = toggled_on
		Game.player.checkKeys()
	else: Changes.addChange(Changes.ArrayElementChange.new(main.focused,&"curse",color,toggled_on))

func _playTest():
	if Game.playState != Game.PLAY_STATE.EDIT:
		await Game.stopTest()
	Game.playTest(main.focused)

func _setLevelStart():
	if main.focused is not PlayerSpawn: return
	if Game.levelStart:
		Game.levelStart.queue_redraw()
	Changes.addChange(Changes.GlobalObjectChange.new(Game,&"levelStart",main.focused))
	main.focused.resetColors()
	main.focused.queue_redraw()
	focus(main.focused, false)

func _setSavestate():
	if main.focused is not PlayerSpawn: return
	if Game.levelStart == main.focused:
		Changes.addChange(Changes.GlobalObjectChange.new(Game,&"levelStart",null))
		main.focused.queue_redraw()
	focus(main.focused, false)
