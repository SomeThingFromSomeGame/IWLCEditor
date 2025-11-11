extends MarginContainer
class_name GameSettings

const MAX_VOLUME:float = db_to_linear(-7)

var playGame:PlayGame

func opened(configFile:ConfigFile) -> void:
	%volume.value = configFile.get_value("game", "volume", 0.5)
	%fullscreen.button_pressed = configFile.get_value("game", "fullscreen", false)
	%smoothingMode.button_pressed = configFile.get_value("game", "smoothingMode", false)
	%simpleLocks.button_pressed = configFile.get_value("game", "simpleLocks", false)

func closed(configFile:ConfigFile) -> void:
	configFile.set_value("game", "volume", %volume.value)
	configFile.set_value("game", "fullscreen", %fullscreen.button_pressed)
	configFile.set_value("game", "smoothingMode", %smoothingMode.button_pressed)
	configFile.set_value("game", "simpleLocks", %simpleLocks.button_pressed)

func _volumeSet(value:float) -> void:
	AudioServer.set_bus_volume_linear(AudioManager.masterBus, lerpf(0,MAX_VOLUME,value))

func _fullscreenSet(toggled_on:bool) -> void:
	if playGame: get_window().mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED

func _smoothingModeSet(toggled_on:bool) -> void:
	if playGame: playGame.gameViewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR if toggled_on else Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

func _simpleLocksSet(toggled_on:bool):
	Game.simpleLocks = toggled_on
