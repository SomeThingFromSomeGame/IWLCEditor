extends Node

var undoStack:Array[RefCounted] = []
var saveBuffered:bool = false

# handles the undo system for the Game
# a lot is copied over from Changes

func start() -> void:
	undoStack = []
	undoStack.append(UndoSeparator.new(Game.player.position))

func bufferSave() -> void:
	saveBuffered = true

func addChange(change:Change) -> Change:
	if change.cancelled: return null
	undoStack.append(change)
	return change

func process() -> void:
	if saveBuffered and Game.player.previousIsOnFloor and Game.player.is_on_floor() and !Game.player.cantSave:
		saveBuffered = false
		if undoStack[-1] is not UndoSeparator: # could happen if something buffers save on the frame before a reset
			undoStack.append(UndoSeparator.new(Game.player.previousPosition))

func undo() -> bool:
	if len(undoStack) == 1: return false
	if undoStack[-1] is UndoSeparator: undoStack.pop_back()
	saveBuffered = false
	Game.player.pauseFrame = true
	Game.player.velocity = Vector2.ZERO
	while true:
		if undoStack[-1] is UndoSeparator:
			Game.player.position = undoStack[-1].position
			Game.player.dropMaster()
			for object in Game.objects.values(): if object is Door and object.type == Door.TYPE.GATE: object.gateBufferCheck = null
			Game.player.checkKeys()
			return true
		var change = undoStack.pop_back()
		change.undo()
	return true # unreachable

func copy(value:Variant) -> Variant:
	if value is C || value is Q: return value.copy()
	else: return value

class Change extends RefCounted:
	var cancelled:bool = false
	# is a singular recorded change
	# do() subsumed to _init()
	func undo() -> void: pass

class UndoSeparator extends RefCounted:
	# indicates the start/end of an undo in the stack; also saves the player's position at that point
	var position:Vector2

	func _init(_position:Vector2) -> void:
		position = _position
	
	func _to_string() -> String:
		return "<UndoSeparator:"+str(position)+">"

class ColorChange extends Change:
	# a change to something in an array of player indexed by colors
	# like key and star
	static func array() -> StringName: return &""

	var color:Game.COLOR
	var before:Variant

	func _init(_color:Game.COLOR, after:Variant) -> void:
		color = _color
		before = GameChanges.copy(Game.player.get(array())[color])
		if before == after or color == Game.COLOR.NONE:
			cancelled = true
			return
		Game.player.get(array())[color] = GameChanges.copy(after)
		Game.player.checkKeys()
	
	func undo() -> void: Game.player.get(array())[color] = GameChanges.copy(before)

	func _to_string() -> String:
		return "<ColorChange:"+str(color)+">"

class KeyChange extends ColorChange:
	# C major -> A minor, for example
	static func array() -> StringName: return &"key"

	func _init(_color:Game.COLOR, after:Variant) -> void:
		if Game.player.star[_color] or color == Game.COLOR.NONE:
			cancelled = true
			return
		super(_color,after)
		for object in Game.objects.values(): if object is Door and object.type == Door.TYPE.GATE: object.gateCheck(Game.player)

class StarChange extends ColorChange:
	# a change to the starred state
	static func array() -> StringName: return &"star"

class CurseChange extends ColorChange:
	# a change to the starred state
	static func array() -> StringName: return &"curse"


class PropertyChange extends Change:
	var id:int
	var property:StringName
	var before:Variant
	var type:GDScript
	
	func _init(component:GameComponent,_property:StringName,after:Variant) -> void:
		id = component.id
		property = _property
		before = Changes.copy(component.get(property))
		if before == after:
			cancelled = true
			return
		type = component.get_script()
		assert(before != after)
		changeValue(Changes.copy(after))

	func undo() -> void: changeValue(Changes.copy(before))
	
	func changeValue(value:Variant) -> void:
		var component:GameComponent
		match type:
			Lock: component = Game.components[id]
			_: component = Game.objects[id]
		component.set(property, value)
		component.propertyGameChangedDo(property)
		component.queue_redraw()
		if component is Door:
			for lock in component.locks: lock.queue_redraw()
	
	func _to_string() -> String:
		return "<PropertyChange:"+str(id)+"."+str(property)+">"
