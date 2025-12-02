extends Control
class_name followWorld

@export var offset:Vector2
var worldOffset:Vector2

@onready var editor:Editor = get_node("/root/editor")

func _process(_delta) -> void:
	scale = Vector2.ONE * editor.cameraZoom
	position = -offset - (editor.editorCamera.position - worldOffset) * scale
