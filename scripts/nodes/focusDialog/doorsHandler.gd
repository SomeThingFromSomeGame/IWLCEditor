extends Handler
class_name DoorsHandler
# for remote lock

var remoteLock:RemoteLock

func setup(_remoteLock:RemoteLock) -> void:
	selected = -1
	remoteLock = _remoteLock
	deleteButtons()
	for index in len(remoteLock.doors):
		var button:DoorsHandlerButton = DoorsHandlerButton.new(index, self)
		buttons.append(button)
		add_child(button)
	move_child(add, -1)
	move_child(remove, -1)
	remove.visible = len(buttons) > 0

func addComponent() -> void: editor.connectionSource = remoteLock
func removeComponent() -> void: pass

func _select(button:Button) -> void:
	if selected == button.index: editor.focusDialog.focus(button.door)
	else: super(button)

class DoorsHandlerButton extends HandlerButton:
	var door:Door

	func _init(_index:int,_handler:DoorsHandler) -> void:
		super(_index, _handler)
		door = handler.remoteLock.doors[index]

	func _draw() -> void:
		pass
