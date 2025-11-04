extends GameObject
class_name RemoteLock
const SCENE:PackedScene = preload("res://scenes/objects/remoteLock.tscn")

const SEARCH_ICON:Texture2D = preload("res://assets/ui/modes/remoteLock.png")
const SEARCH_NAME:String = "Remote Lock"
const SEARCH_KEYWORDS:Array[String] = []

func getOffset() -> Vector2: return Lock.offsetFromType(sizeType)

func getAvailableConfigurations() -> Array[Array]: return Lock.availableConfigurations(count, type)

const CREATE_PARAMETERS:Array[StringName] = [
	&"position"
]
const EDITOR_PROPERTIES:Array[StringName] = [
	&"id", &"position", &"size",
	&"color", &"type", &"configuration", &"sizeType", &"count", &"isPartial", &"denominator", &"negated",
]

var color:Game.COLOR = Game.COLOR.WHITE
var type:Lock.TYPE = Lock.TYPE.NORMAL
var configuration:Lock.CONFIGURATION = Lock.CONFIGURATION.spr1A
var sizeType:Lock.SIZE_TYPE = Lock.SIZE_TYPE.AnyS
var count:C = C.ONE
var isPartial:bool = false # for partial blast
var denominator:C = C.ONE # for partial blast
var negated:bool = false

var drawGlitch:RID
var drawScaled:RID
var drawMain:RID
var drawConfiguration:RID

func _init() -> void: size = Vector2(18,18)

func _ready() -> void:
	drawGlitch = RenderingServer.canvas_item_create()
	drawScaled = RenderingServer.canvas_item_create()
	drawMain = RenderingServer.canvas_item_create()
	drawConfiguration = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(drawGlitch,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawScaled,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawMain,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawConfiguration,get_canvas_item())
	game.connect(&"goldIndexChanged",queue_redraw)

func _draw() -> void:
	RenderingServer.canvas_item_clear(drawGlitch)
	RenderingServer.canvas_item_clear(drawScaled)
	RenderingServer.canvas_item_clear(drawMain)
	RenderingServer.canvas_item_clear(drawConfiguration)
	Lock.drawLock(game,drawGlitch,drawScaled,drawMain,drawConfiguration,
		size,colorAfterCurse(),colorAfterGlitch(),type,configuration,sizeType,count,isPartial,denominator,negated,
		Lock.getFrameHighColor(isNegative(), negated).blend(Color(animColor,animAlpha)),
		Lock.getFrameMainColor(isNegative(), negated).blend(Color(animColor,animAlpha)),
		Lock.getFrameDarkColor(isNegative(), negated).blend(Color(animColor,animAlpha)),
		isNegative()
	)

func getDrawPosition() -> Vector2: return position - getOffset()

func propertyChangedInit(property:StringName) -> void:
	if property == &"size": _comboDoorSizeChanged()
	if property in [&"count", &"sizeType", &"type"]: _setAutoConfiguration()
	
	if property == &"type":
		if (type == Lock.TYPE.BLANK or (type == Lock.TYPE.ALL and !mods.active(&"C3"))) and count.neq(1):
			changes.addChange(Changes.PropertyChange.new(game,self,&"count",C.ONE))
		if type == Lock.TYPE.BLAST:
			if (count.abs().neq(1)) and !mods.active(&"C3"): changes.addChange(Changes.PropertyChange.new(game,self,&"count",C.ONE if count.eq(0) else count.axis()))
		elif type == Lock.TYPE.ALL:
			if !isPartial and denominator.neq(1): changes.addChange(Changes.PropertyChange.new(game,self,&"denominator",C.ONE))
		else:
			if denominator.neq(1): changes.addChange(Changes.PropertyChange.new(game,self,&"denominator",C.ONE))
			if isPartial: changes.addChange(Changes.PropertyChange.new(game,self,&"isPartial",false))

	if property == &"isPartial" and !isPartial:
		changes.addChange(Changes.PropertyChange.new(game,self,&"denominator", C.ONE if count.isComplex() or count.eq(0) or type == Lock.TYPE.ALL else count.axis()))

func propertyChangedDo(property:StringName) -> void:
	super(property)
	if property == &"size":
		%shape.shape.size = size
		%shape.position = size/2 - getOffset()

func _comboDoorConfigurationChanged(newSizeType:Lock.SIZE_TYPE,newConfiguration:Lock.CONFIGURATION=Lock.CONFIGURATION.NONE) -> void: Lock.comboDoorConfigurationChanged(game,self,newSizeType,newConfiguration)
func _comboDoorSizeChanged() -> void: Lock.comboDoorSizeChanged(game,self)
func _setAutoConfiguration() -> void: changes.addChange(Changes.PropertyChange.new(game,self,&"configuration",Lock.getAutoConfiguration(self)))

# ==== PLAY ==== #
var cursed:bool = false
var curseColor:Game.COLOR
var glitchMimic:Game.COLOR = Game.COLOR.GLITCH
var curseGlitchMimic:Game.COLOR = Game.COLOR.GLITCH
var satisfied:bool = false
var cost:C = C.ZERO
var gameFrozen:bool = false
var gameCrumbled:bool = false
var gamePainted:bool = false

var animColor:Color
var animAlpha:float = 0

func _process(delta:float) -> void:
	if animAlpha > 0:
		animAlpha -= delta*3
		queue_redraw()
		if animAlpha <= 0: animAlpha = 0

func start() -> void:
	animAlpha = 0

func stop() -> void:
	cursed = false
	glitchMimic = Game.COLOR.GLITCH
	curseGlitchMimic = Game.COLOR.GLITCH
	satisfied = false
	cost = C.ZERO

func check(player:Player) -> void:
	satisfied = canOpen(player)
	cost = getCost(player)
	if satisfied: AudioManager.play(preload("res://resources/sounds/remoteLock/success.wav"))
	else: AudioManager.play(preload("res://resources/sounds/remoteLock/fail.wav"))
	blinkAnim()

func blinkAnim() -> void:
	animAlpha = 1
	animColor = Color("#00ff66") if satisfied else Color("#ff0066")

func canOpen(player:Player) -> bool:
	if gameFrozen or gameCrumbled or gamePainted:
		if colorAfterGlitch() == Game.COLOR.PURE: return false
		if int(gameFrozen) + int(gameCrumbled) + int(gamePainted) > 1: return false
		if gameFrozen and player.key[Game.COLOR.ICE].eq(0): return false
		if gameCrumbled and player.key[Game.COLOR.MUD].eq(0): return false
		if gamePainted and player.key[Game.COLOR.GRAFFITI].eq(0): return false
	return Lock.getLockCanOpen(self, player)

func getCost(player:Player) -> C: return Lock.getLockCost(self,player,C.ONE)

func colorAfterCurse() -> Game.COLOR:
	if cursed and curseColor != Game.COLOR.PURE: return curseColor
	return color

func colorAfterGlitch() -> Game.COLOR:
	var base:Game.COLOR = colorAfterCurse()
	if base == Game.COLOR.GLITCH: return curseGlitchMimic if cursed else glitchMimic
	return base

func colorAfterAurabreaker() -> Game.COLOR:
	if int(gameFrozen) + int(gameCrumbled) + int(gamePainted) > 1: return colorAfterGlitch()
	if gameFrozen: return Game.COLOR.ICE
	if gameCrumbled: return Game.COLOR.MUD
	if gamePainted: return Game.COLOR.GRAFFITI
	return colorAfterGlitch()

func isNegative() -> bool:
	if type == Lock.TYPE.ALL: return false
	return (denominator if type == Lock.TYPE.BLAST else count).sign() < 0

func effectiveCount(_ipow:C=C.ONE) -> C: return count
func effectiveDenominator(_ipow:C=C.ONE) -> C: return denominator
