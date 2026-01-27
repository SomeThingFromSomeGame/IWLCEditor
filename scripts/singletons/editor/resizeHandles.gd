extends Control
class_name ResizeHandles

@onready var editor:Editor = get_node("/root/editor")
var target:GameComponent

func _process(_delta) -> void:
	if editor.edgeResizing: target = null
	elif editor.settingsOpen and editor.settingsMenu.levelSettings.visible:
		target = editor.levelBoundsObject
	else:
		target = null
		if editor.sizeDragging(): target = editor.componentDragged
		if !target: target = editor.focusDialog.componentFocused
		if !target or (target is Lock and target.parent.type == Door.TYPE.SIMPLE) or (target is KeyCounterElement): target = editor.focusDialog.focused
		if target and target.get_script() not in Game.RESIZABLE_COMPONENTS: target = null
	visible = !!target
	if target:
		position = editor.worldspaceToScreenspace(target.getDrawPosition())
		size = target.getDrawSize() * editor.cameraZoom / Game.uiScale
		%diagonals.visible = target is not KeyCounter
		%vertical.visible = target is not KeyCounter

func _topleft() -> void: 		editor.grab_focus(); editor.startSizeDrag(target, Vector2(-1,-1))
func _top() -> void: 			editor.grab_focus(); editor.startSizeDrag(target, Vector2(0,-1))
func _topright() -> void: 		editor.grab_focus(); editor.startSizeDrag(target, Vector2(1,-1))
func _left() -> void: 			editor.grab_focus(); editor.startSizeDrag(target, Vector2(-1,0))
func _right() -> void: 			editor.grab_focus(); editor.startSizeDrag(target, Vector2(1,0))
func _bottomleft() -> void: 	editor.grab_focus(); editor.startSizeDrag(target, Vector2(-1,1))
func _bottom() -> void: 		editor.grab_focus(); editor.startSizeDrag(target, Vector2(0,1))
func _bottomright() -> void: 	editor.grab_focus(); editor.startSizeDrag(target, Vector2(1,1))

func _finished() -> void: editor.grab_click_focus()
