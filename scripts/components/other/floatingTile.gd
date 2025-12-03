extends GameObject
class_name FloatingTile
const SCENE:PackedScene = preload("res://scenes/objects/floatingTile.tscn")

const SEARCH_ICON:Texture2D = TEXTURE
const SEARCH_NAME:String = "Floating Tile"
const SEARCH_KEYWORDS:Array[String] = []

const TEXTURE:Texture2D = preload("res://assets/ui/modes/tile.png")

const CREATE_PARAMETERS:Array[StringName] = [
	&"position"
]
const PROPERTIES:Array[StringName] = [
	&"id", &"position",
]
static var ARRAYS:Dictionary[StringName,GDScript] = {}

var drawMain:RID

func _init() -> void: size = Vector2(32,32)

func _ready() -> void:
	drawMain = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(drawMain,get_canvas_item())

func _draw() -> void:
	RenderingServer.canvas_item_clear(drawMain)
	RenderingServer.canvas_item_add_texture_rect(drawMain,Rect2(Vector2.ZERO,size),TEXTURE)
