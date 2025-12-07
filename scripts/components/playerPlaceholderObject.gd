extends PlaceholderObject
class_name PlayerPlaceholderObject

func outlineTex() -> Texture2D:
	return Game.player.getCurrentSprite()

func getOffset() -> Vector2:
	return Vector2(10, 11)

func getDrawSize() -> Vector2:
	return Vector2(32,32)

func propertyChangedDo(property:StringName) -> void:
	match property:
		&"position":
			Game.player.position = position + Vector2(6, 12)

func deletedInit() -> void:
	Game.stopTest()
