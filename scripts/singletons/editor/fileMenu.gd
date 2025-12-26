extends MenuButton
class_name FileMenu

@onready var menu:PopupMenu = get_popup()

func _ready() -> void:
	menu.theme_type_variation = &"PopupMenuFiles"
	menu.id_pressed.connect(optionPressed)

func optionPressed(id:int) -> void:
	match id:
		# FILE
		0: Saving.confirmAction = Saving.ACTION.NONE; Saving.new()
		1: Saving.open()
		2: Saving.confirmAction = Saving.ACTION.NONE; Saving.save()
		3: Saving.confirmAction = Saving.ACTION.NONE; Saving.saveAs()
		4: Saving.openExportWindow()
		5: OS.shell_open(ProjectSettings.globalize_path("user://puzzles"))
		# CONFIG
		7: Mods.openModsWindow()
		8: Game.play()
