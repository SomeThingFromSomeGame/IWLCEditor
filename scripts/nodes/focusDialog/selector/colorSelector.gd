extends Selector
class_name ColorSelector

const NONE_COLOR:Texture2D = preload("res://assets/ui/focusDialog/noneColor.png")

var spacers:Array[Control]

func _ready() -> void:
	columns = 8
	options = range(Game.COLORS)
	defaultValue = Game.COLOR.WHITE
	buttonType = ColorSelectorButton
	super()
	for button in buttons:
		Explainer.addControl(button,QuicksetExplanation.new("[%s+$q]Set "+Game.COLOR_NAMES[button.value].to_lower()+" color", [&"quicksetColor"], ColorQuicksetSetting.matches, button.value))

func onlyFlatColors() -> void:
	for color in Game.NONFLAT_COLORS: buttons[color].visible = false

func changedMods() -> void:
	var colors:Array[Game.COLOR] = Mods.colors()
	for button in buttons: button.visible = false
	for color in colors: buttons[color].visible = true
	if len(colors) < 15: columns = 7
	else: columns = 8
	
	for spacer in spacers: spacer.queue_free()
	spacers.clear()
	@warning_ignore("integer_division")
	for i in (columns - 1 - (len(colors)-1) % columns)/2:
		var spacer:Control = Control.new()
		spacers.append(spacer)
		add_child(spacer)
		move_child(spacer,0)

	if selected not in colors: buttons[defaultValue].button_pressed = true

class ColorSelectorButton extends SelectorButton:
	var drawMain:RID

	func _init(_value:Game.COLOR, _selector:Selector):
		custom_minimum_size = Vector2(20,20)
		z_index = 1
		super(_value, _selector)
	
	func _ready() -> void:
		drawMain = RenderingServer.canvas_item_create()
		if value == Game.COLOR.GLITCH:
			RenderingServer.canvas_item_set_material(drawMain,Game.GLITCH_MATERIAL.get_rid())
		RenderingServer.canvas_item_set_z_index(drawMain,-1)
		RenderingServer.canvas_item_set_parent(drawMain,get_canvas_item())
		await get_tree().process_frame
		if value in Game.ANIMATED_COLORS: Game.connect(&"goldIndexChanged",queue_redraw)
		await get_tree().process_frame
		queue_redraw()
	
	func _draw() -> void:
		RenderingServer.canvas_item_clear(drawMain)
		var rect:Rect2 = Rect2(Vector2.ONE, size-Vector2(2,2))
		if value in Game.TEXTURED_COLORS: RenderingServer.canvas_item_add_texture_rect(drawMain,rect,Game.COLOR_TEXTURES.current([value]))
		elif value == Game.COLOR.NONE: RenderingServer.canvas_item_add_texture_rect(drawMain,rect,NONE_COLOR)
		else: RenderingServer.canvas_item_add_rect(drawMain,rect,Game.mainTone[value])
