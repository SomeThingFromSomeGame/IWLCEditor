extends Resource
class_name SerialisedUndoStack

@export var serialisedStack:Array[Array] = []

func _init(stack:Array[RefCounted]=[]) -> void:
	for change in stack:
		serialisedStack.append(change.serialise())

func build() -> Array[RefCounted]:
	var stack:Array[RefCounted] = []
	for serialisedChange in serialisedStack:
		var change:RefCounted = GameChanges.CHANGE_TYPES[serialisedChange[0]].deserialise(serialisedChange)
		if change: stack.append(change)
	return stack
