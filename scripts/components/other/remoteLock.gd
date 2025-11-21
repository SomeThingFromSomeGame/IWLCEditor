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
const PROPERTIES:Array[StringName] = [
	&"id", &"position", &"size",
	&"color", &"type", &"configuration", &"sizeType", &"count", &"zeroI", &"isPartial", &"denominator", &"negated", &"armament",
	&"frozen", &"crumbled", &"painted"
]
static var ARRAYS:Dictionary[StringName,GDScript] = {
	&"doors":Door
}

var color:Game.COLOR = Game.COLOR.WHITE
var type:Lock.TYPE = Lock.TYPE.NORMAL
var configuration:Lock.CONFIGURATION = Lock.CONFIGURATION.spr1A
var sizeType:Lock.SIZE_TYPE = Lock.SIZE_TYPE.AnyS
var count:C = C.ONE
var zeroI:bool = false
var isPartial:bool = false # for partial blast
var denominator:C = C.ONE # for partial blast
var negated:bool = false
var armament:bool = false
var frozen:bool = false
var crumbled:bool = false
var painted:bool = false

var doors:Array[Door] = []

var drawConnections:RID
var drawGlitch:RID
var drawScaled:RID
var drawAuraBreaker:RID
var drawMain:RID
var drawConfiguration:RID
var drawCrumbled:RID
var drawPainted:RID
var drawFrozen:RID

func _init() -> void: size = Vector2(18,18)

func _ready() -> void:
	drawConnections = RenderingServer.canvas_item_create()
	drawScaled = RenderingServer.canvas_item_create()
	drawAuraBreaker = RenderingServer.canvas_item_create()
	drawGlitch = RenderingServer.canvas_item_create()
	drawMain = RenderingServer.canvas_item_create()
	drawConfiguration = RenderingServer.canvas_item_create()
	drawCrumbled = RenderingServer.canvas_item_create()
	drawPainted = RenderingServer.canvas_item_create()
	drawFrozen = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_z_index(drawConnections,-1)
	RenderingServer.canvas_item_set_parent(drawConnections,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawScaled,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawAuraBreaker,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawGlitch,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawMain,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawConfiguration,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawCrumbled,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawPainted,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawFrozen,get_canvas_item())
	Game.connect(&"goldIndexChanged",queue_redraw)

func _draw() -> void:
	RenderingServer.canvas_item_clear(drawConnections)
	RenderingServer.canvas_item_clear(drawScaled)
	RenderingServer.canvas_item_clear(drawAuraBreaker)
	RenderingServer.canvas_item_clear(drawGlitch)
	RenderingServer.canvas_item_clear(drawMain)
	RenderingServer.canvas_item_clear(drawConfiguration)
	RenderingServer.canvas_item_clear(drawCrumbled)
	RenderingServer.canvas_item_clear(drawPainted)
	RenderingServer.canvas_item_clear(drawFrozen)
	if !active and Game.playState == Game.PLAY_STATE.PLAY: return
	Lock.drawLock(drawScaled,drawAuraBreaker,drawGlitch,drawMain,drawConfiguration,
		size,colorAfterCurse(),colorAfterGlitch(),type,configuration,sizeType,count,zeroI,isPartial,denominator,negated,armament,
		Lock.getFrameHighColor(isNegative(), negated).blend(Color(animColor,animAlpha)),
		Lock.getFrameMainColor(isNegative(), negated).blend(Color(animColor,animAlpha)),
		Lock.getFrameDarkColor(isNegative(), negated).blend(Color(animColor,animAlpha)),
		isNegative()
	)
	var from:Vector2 = size/2-getOffset()
	var index:int = 0
	for door in doors:
		if !door.active and Game.playState == Game.PLAY_STATE.PLAY: continue
		var to:Vector2 = door.position+door.size/2 - position
		if editor and self == editor.focusDialog.focused and index == editor.focusDialog.doorDialog.doorsHandler.selected:
			RenderingServer.canvas_item_add_line(drawConnections,from,to,Color("#00a2ff"),4+4/editor.cameraZoom)
		RenderingServer.canvas_item_add_line(drawConnections,from,to,Color.WHITE if satisfied or Game.playState == Game.PLAY_STATE.EDIT else Color.BLACK,4)
		RenderingServer.canvas_item_add_line(drawConnections,from,to,Game.mainTone[color] if satisfied or Game.playState == Game.PLAY_STATE.EDIT else Color.BLACK,2)
		index += 1
	if editor and self == editor.connectionSource:
		var to:Vector2 = editor.mouseWorldPosition - position
		RenderingServer.canvas_item_add_line(drawConnections,from,to,Color.WHITE if satisfied or Game.playState == Game.PLAY_STATE.EDIT else Color.BLACK,4)
		RenderingServer.canvas_item_add_line(drawConnections,from,to,Game.mainTone[color] if satisfied or Game.playState == Game.PLAY_STATE.EDIT else Color.BLACK,2)
	# auras
	Door.drawAuras(drawCrumbled,drawPainted,drawFrozen,
		frozen if Game.playState == Game.PLAY_STATE.EDIT else gameFrozen,
		crumbled if Game.playState == Game.PLAY_STATE.EDIT else gameCrumbled,
		painted if Game.playState == Game.PLAY_STATE.EDIT else gamePainted,
		Rect2(-getOffset(),size))

func getDrawPosition() -> Vector2: return position - getOffset()

func propertyChangedInit(property:StringName) -> void:
	if property == &"size": _setSizeType()
	if property in [&"count", &"sizeType", &"type"]: _setAutoConfiguration()
	
	Lock.lockPropertyChangedInit(self, property)

func propertyChangedDo(property:StringName) -> void:
	super(property)
	if property == &"size":
		%shape.shape.size = size
		%shape.position = size/2 - getOffset()

func receiveMouseInput(event:InputEventMouse) -> bool:
	# resizing
	if editor.componentDragged: return false
	var dragCornerSize:Vector2 = Vector2(8,8)/editor.cameraZoom
	var diffSign:Vector2 = Editor.rectSign(Rect2(position-getOffset()+dragCornerSize,size-dragCornerSize*2), editor.mouseWorldPosition)
	var dragPivot:Editor.SIZE_DRAG_PIVOT = Editor.SIZE_DRAG_PIVOT.NONE
	match diffSign:
		Vector2(-1,-1): dragPivot = Editor.SIZE_DRAG_PIVOT.TOP_LEFT;	editor.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
		Vector2(0,-1): dragPivot = Editor.SIZE_DRAG_PIVOT.TOP;			editor.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		Vector2(1,-1): dragPivot = Editor.SIZE_DRAG_PIVOT.TOP_RIGHT;	editor.mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
		Vector2(-1,0): dragPivot = Editor.SIZE_DRAG_PIVOT.LEFT;			editor.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		Vector2(1,0): dragPivot = Editor.SIZE_DRAG_PIVOT.RIGHT;			editor.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		Vector2(-1,1): dragPivot = Editor.SIZE_DRAG_PIVOT.BOTTOM_LEFT;	editor.mouse_default_cursor_shape = Control.CURSOR_BDIAGSIZE
		Vector2(0,1): dragPivot = Editor.SIZE_DRAG_PIVOT.BOTTOM;		editor.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		Vector2(1,1): dragPivot = Editor.SIZE_DRAG_PIVOT.BOTTOM_RIGHT;	editor.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	if dragPivot != Editor.SIZE_DRAG_PIVOT.NONE and Editor.isLeftClick(event):
		editor.startSizeDrag(self, dragPivot)
		return true
	return false

func _setAutoConfiguration() -> void: Changes.addChange(Changes.PropertyChange.new(self,&"configuration",Lock.getAutoConfiguration(self)))

func _setSizeType() -> void:
	var match:int = Lock.SIZES.find(size)
	var newSizeType:Lock.SIZE_TYPE = Lock.SIZE_TYPE.ANY if match == -1 else match as Lock.SIZE_TYPE
	Changes.addChange(Changes.PropertyChange.new(self,&"sizeType",newSizeType))
	queue_redraw()

func _connectTo(door:Door) -> void:
	Changes.addChange(Changes.ComponentArrayAppendChange.new(self,&"doors",door))
	Changes.addChange(Changes.ComponentArrayAppendChange.new(door,&"remoteLocks",self))

func _disconnectTo(door:Door) -> void:
	Changes.addChange(Changes.ComponentArrayPopAtChange.new(self,&"doors",doors.find(door)))
	Changes.addChange(Changes.ComponentArrayPopAtChange.new(door,&"remoteLocks",door.remoteLocks.find(self)))

func deletedInit() -> void:
	for door in doors:
		Changes.addChange(Changes.ComponentArrayPopAtChange.new(door,&"remoteLocks",door.remoteLocks.find(self)))

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
var curseTimer:float = 0

func _process(delta:float) -> void:
	if editor and self == editor.connectionSource: queue_redraw()
	if cursed and active:
		curseTimer += delta
		if curseTimer >= 2:
			curseTimer -= 2
			makeCurseParticles(curseColor,1,0.2,0.3)
	if animAlpha > 0:
		animAlpha -= delta*3
		queue_redraw()
		if animAlpha <= 0: animAlpha = 0

func start() -> void:
	animAlpha = 0
	gameFrozen = frozen
	gameCrumbled = crumbled
	gamePainted = painted
	cost = getCost(Game.player)

func stop() -> void:
	cursed = false
	glitchMimic = Game.COLOR.GLITCH
	curseGlitchMimic = Game.COLOR.GLITCH
	satisfied = false
	cost = C.ZERO
	curseTimer = 0

func check(player:Player) -> void:
	if gameFrozen or gameCrumbled or gamePainted:
		if colorAfterGlitch() == Game.COLOR.PURE: return
		if int(gameFrozen) + int(gameCrumbled) + int(gamePainted) > 1: return
		if gameFrozen and player.key[Game.COLOR.ICE].eq(0): return
		if gameCrumbled and player.key[Game.COLOR.MUD].eq(0): return
		if gamePainted and player.key[Game.COLOR.GRAFFITI].eq(0): return
	var satisfiedBefore:bool = satisfied
	var costBefore:C = cost.copy()
	GameChanges.addChange(GameChanges.PropertyChange.new(self,&"satisfied",canOpen(player)))
	GameChanges.addChange(GameChanges.PropertyChange.new(self,&"cost",getCost(player)))
	if colorAfterAurabreaker() == Game.COLOR.NONE and !satisfied: Game.crash(); return
	if !(satisfiedBefore == satisfied and costBefore.eq(cost)):
		if satisfied: AudioManager.play(preload("res://resources/sounds/remoteLock/success.wav"))
		else: AudioManager.play(preload("res://resources/sounds/remoteLock/fail.wav"))
		for door in doors: if door.type == Door.TYPE.GATE: door.gateCheck(player)
		blinkAnim()
		GameChanges.bufferSave()

func blinkAnim() -> void:
	animAlpha = 1
	animColor = Color("#00ff66") if satisfied else Color("#ff0066")

func canOpen(player:Player) -> bool: return Lock.getLockCanOpen(self, player)

func getCost(player:Player) -> C: return Lock.getLockCost(self,player,C.ONE)

func colorAfterCurse() -> Game.COLOR:
	if cursed and curseColor != Game.COLOR.PURE: return curseColor
	return color

func colorAfterGlitch() -> Game.COLOR:
	var base:Game.COLOR = colorAfterCurse()
	if base == Game.COLOR.GLITCH: return curseGlitchMimic if cursed and curseColor != Game.COLOR.PURE else glitchMimic
	return base

func colorAfterAurabreaker() -> Game.COLOR:
	if int(gameFrozen) + int(gameCrumbled) + int(gamePainted) > 1 or armament: return colorAfterGlitch()
	if gameFrozen: return Game.COLOR.ICE
	if gameCrumbled: return Game.COLOR.MUD
	if gamePainted: return Game.COLOR.GRAFFITI
	return colorAfterGlitch()


func isNegative() -> bool:
	if type in [Lock.TYPE.BLAST, Lock.TYPE.ALL]:
		if count.isComplex() or denominator.isComplex(): return false
		return effectiveDenominator().sign() < 0
	return effectiveCount().sign() < 0

func effectiveCount(_ipow:C=C.ONE) -> C: return count
func effectiveDenominator(_ipow:C=C.ONE) -> C: return denominator

func checkDoors() -> void:
	var any:bool = false
	for door in doors:
		if door.active: any = true
	GameChanges.addChange(GameChanges.PropertyChange.new(self,&"active",any))
	queue_redraw()

func setGlitch(setColor:Game.COLOR) -> void:
	GameChanges.addChange(GameChanges.PropertyChange.new(self, &"glitchMimic", setColor))
	queue_redraw()

func curseCheck(player:Player) -> void:
	if colorAfterGlitch() == Game.COLOR.PURE or armament: return
	if player.curseMode > 0 and color != player.curseColor and (!cursed or curseColor != player.curseColor):
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"cursed",true))
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"curseColor",player.curseColor))
		makeCurseParticles(curseColor, 1, 0.2, 0.5)
		AudioManager.play(preload("res://resources/sounds/door/curse.wav"))
		GameChanges.bufferSave()
	elif player.curseMode < 0 and cursed and curseColor == player.curseColor:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"cursed",false))
		if curseColor == Game.COLOR.GLITCH:
			GameChanges.addChange(GameChanges.PropertyChange.new(self,&"curseGlitchMimic",Game.COLOR.GLITCH))
		makeCurseParticles(Game.COLOR.BROWN, -1, 0.2, 0.5)
		AudioManager.play(preload("res://resources/sounds/door/decurse.wav"))
		GameChanges.bufferSave()

func makeCurseParticles(particleColor:Game.COLOR, mode:int, scaleMin:float=1,scaleMax:float=1) -> void:
	for y in floor((size.y)/16):
		for x in floor((size.x)/16):
			add_child(CurseParticle.Temporary.new(particleColor, mode, Vector2(x,y)*16-getOffset()+Vector2.ONE*randf_range(4,12), randf_range(scaleMin,scaleMax)))

func auraCheck(player:Player) -> void:
	var deAuraed:bool = false
	if player.auraRed and gameFrozen and colorAfterGlitch() != Game.COLOR.MAROON:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"gameFrozen",false))
		makeDebris(Door.Debris, Game.COLOR.WHITE)
		deAuraed = true
	if player.auraGreen and gameCrumbled and colorAfterGlitch() != Game.COLOR.FOREST:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"gameCrumbled",false))
		makeDebris(Door.Debris, Game.COLOR.BROWN)
		deAuraed = true
	if player.auraBlue and gamePainted and colorAfterGlitch() != Game.COLOR.NAVY:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"gamePainted",false))
		makeDebris(Door.Debris, Game.COLOR.ORANGE)
		deAuraed = true
	var auraed:bool = false
	if player.auraMaroon and !gameFrozen and colorAfterGlitch() != Game.COLOR.RED and colorAfterCurse() != Game.COLOR.ICE:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"gameFrozen",true))
		makeDebris(Door.Debris, Game.COLOR.WHITE)
		auraed = true
	if player.auraForest and !gameCrumbled and colorAfterGlitch() != Game.COLOR.GREEN and colorAfterCurse() != Game.COLOR.MUD:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"gameCrumbled",true))
		makeDebris(Door.Debris, Game.COLOR.BROWN)
		auraed = true
	if player.auraNavy and !gamePainted and colorAfterGlitch() != Game.COLOR.BLUE and colorAfterCurse() != Game.COLOR.GRAFFITI:
		GameChanges.addChange(GameChanges.PropertyChange.new(self,&"gamePainted",true))
		makeDebris(Door.Debris, Game.COLOR.ORANGE)
		auraed = true
	
	if deAuraed or auraed:
		AudioManager.play(preload("res://resources/sounds/door/deaura.wav"))
		GameChanges.bufferSave()

func makeDebris(debrisType:GDScript, debrisColor:Game.COLOR) -> void:
	for y in floor(size.y/16):
		for x in floor(size.x/16):
			add_child(debrisType.new(debrisColor,Vector2(x*16,y*16)))

func propertyGameChangedDo(property:StringName) -> void:
	if property == &"active":
		%interact.process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
