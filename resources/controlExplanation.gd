extends Resource
class_name ControlExplanation

@export var name:String
@export var hotkeys:Dictionary[String,String]

func _init(_name:String="", _hotkeys:Dictionary[String,String]={}) -> void:
	name = _name
	hotkeys = _hotkeys

func _to_string() -> String:
	return name + ("(" if name else "") + " ".join(hotkeys.keys().map(func(hotkey):
		if "[img]" in hotkey: return hotkey + hotkeys[hotkey]
		else: return "[" + hotkey + "]" + hotkeys[hotkey]
	))+ (")" if name else "")
