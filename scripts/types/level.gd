extends RefCounted
class_name Level

var shortNumber:String = "X-X"
var number:String = ""
var name:String = "Unnamed Level":
	set(value):
		name = value
		if active: Game.updateWindowName()
var description:String = ""
var author:String = ""
var size:Vector2i = Vector2i(800,608):
	set(value):
		size = value
		if active: Game.levelBounds.size = size

var active:bool = false

func activate() -> void:
	active = true
	Game.level = self
	Game.updateWindowName()
	Game.levelBounds.size = size

func _get_property_list() -> Array[Dictionary]:
	return [
		{"name":"shortNumber","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"number","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"name","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"description","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"author","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"size","type":TYPE_VECTOR2I,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
	]
