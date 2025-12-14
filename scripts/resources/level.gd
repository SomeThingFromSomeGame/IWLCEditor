extends Resource
class_name Level

@export var shortNumber:String = "X-X"
@export var number:String = ""
@export var name:String = "Unnamed Level":
	set(value):
		name = value
		if active: Game.updateWindowName()
@export var description:String = ""
@export var author:String = ""
@export var position:Vector2i = Vector2i(0,0):
	set(value):
		position = value
		if active: Game.levelBounds.position = position
@export var size:Vector2i = Vector2i(800,608):
	set(value):
		size = value
		if active: Game.levelBounds.size = size

var active:bool = false

func activate() -> void:
	active = true
	Game.level = self
	Game.updateWindowName()
	Game.levelBounds.position = position
	Game.levelBounds.size = size
