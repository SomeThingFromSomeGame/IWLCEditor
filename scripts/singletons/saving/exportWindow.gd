extends Window
class_name ExportWindow

enum EXPORT_TYPES {ROOM_GMX}

@onready var editor:Editor = get_node("/root/editor")
var path:String = ""
var type:EXPORT_TYPES = EXPORT_TYPES.ROOM_GMX
var exporter:GDScript

var interacted:PanelContainer

func _ready() -> void:
	editor.exportWindow = self
	_setType(type)
	%roomIDEdit.context = self
	%idIterStartEdit.context = self
	%roomIDEdit.setValue(M.N(ExportRoomGMX.roomID), true)
	%idIterStartEdit.setValue(M.N(ExportRoomGMX.idIter), true)

func _setType(index:int) -> void:
	type = index as EXPORT_TYPES
	%pathDialog.clear_filters()
	var fileExtension:String
	var fileTypeDesc:String
	match type:
		EXPORT_TYPES.ROOM_GMX:
			fileExtension = ".room.gmx"
			fileTypeDesc = "GameMaker Room File"
			%roomGMX.visible = true
			exporter = ExportRoomGMX
	%pathDialog.add_filter("*"+fileExtension, fileTypeDesc)
	%pathDialog.current_dir = "exports"
	%pathDialog.current_file = "exports/"+Game.level.name+fileExtension
	_setPath("")

func _close() -> void: queue_free()

func _changePath() -> void:
	if path: %pathDialog.current_file = path
	%pathDialog.visible = true
	%pathDialog.grab_focus()

func _setPath(_path:String) -> void:
	path = _path
	%path.text = path
	%export.disabled = !path

func _export():
	var file:FileAccess = FileAccess.open(path,FileAccess.ModeFlags.WRITE)
	exporter.exportFile(file)
	file.close()
	_close()

func _input(event:InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and interacted:
		interacted.receiveKey(event)

func tabbed(_edit:PanelContainer) -> void: pass

func interact(edit:PanelContainer) -> void:
	deinteract()
	edit.theme_type_variation = &"NumberEditPanelContainerNewlyInteracted"
	interacted = edit
	edit.newlyInteracted = true

func deinteract() -> void:
	if !interacted: return
	interacted.theme_type_variation = &"NumberEditPanelContainer"
	if interacted is NumberEdit: interacted.bufferedNegative = false
	elif interacted is AxialNumberEdit and !interacted.isZeroI: interacted.bufferedSign = M.ONE
	interacted.setValue(interacted.value,true)
	interacted = null

# .ROOM.GMX
func _roomIDSet(value:PackedInt64Array) -> void:
	ExportRoomGMX.roomID = M.toInt(value)

func _idIterStartSet(value:PackedInt64Array) -> void:
	ExportRoomGMX.idIterStart = M.toInt(value)
