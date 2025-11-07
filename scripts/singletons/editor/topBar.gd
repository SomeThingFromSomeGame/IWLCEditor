extends MarginContainer
class_name TopBar

@onready var editor:Editor = get_node("/root/editor")
@onready var play:Button = %play

func _updateButtons() -> void:
	%modes.visible = editor.game.playState != Game.PLAY_STATE.PLAY and !editor.settingsOpen

	play.visible = editor.game.playState != Game.PLAY_STATE.PLAY and !editor.settingsOpen
	%pause.visible = editor.game.playState == Game.PLAY_STATE.PLAY and !editor.settingsOpen
	%stop.visible = editor.game.playState != Game.PLAY_STATE.EDIT and !editor.settingsOpen
	%settingTabs.visible = editor.settingsOpen

	play.disabled = !(editor.game.playState == Game.PLAY_STATE.PAUSED || editor.game.levelStart)

func _play() -> void: editor.game.playTest(editor.game.levelStart)
func _pause() -> void: editor.game.pauseTest()
func _stop() -> void: editor.game.stopTest()
