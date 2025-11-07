extends RefCounted
class_name Level

var game:Game

var shortNumber:String = "X-X"
var number:String = ""
var name:String = "Unnamed Level":
	set(value):
		name = value
		if game: game.updateWindowName()
var description:String = ""
var author:String = ""

func _get_property_list() -> Array[Dictionary]:
	return [
		{"name":"shortNumber","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"number","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"name","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"description","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
		{"name":"author","type":TYPE_STRING,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE},
	]
