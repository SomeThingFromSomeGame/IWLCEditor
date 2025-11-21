extends GameObject
class_name KeyBulk
const SCENE:PackedScene = preload("res://scenes/objects/keyBulk.tscn")

const TYPES:int = 5
enum TYPE {NORMAL, EXACT, STAR, ROTOR, CURSE}

# colors that use textures
const TEXTURE_COLORS:Array[Game.COLOR] = [Game.COLOR.MASTER, Game.COLOR.PURE, Game.COLOR.STONE, Game.COLOR.DYNAMITE, Game.COLOR.QUICKSILVER, Game.COLOR.ICE, Game.COLOR.MUD, Game.COLOR.GRAFFITI]

static var FILL:KeyTextureLoader = KeyTextureLoader.new("res://assets/game/key/$t/fill.png")
static var FRAME:KeyTextureLoader = KeyTextureLoader.new("res://assets/game/key/$t/frame.png")
static var FILL_GLITCH:KeyTextureLoader = KeyTextureLoader.new("res://assets/game/key/$t/fillGlitch.png")
static var FRAME_GLITCH:KeyTextureLoader = KeyTextureLoader.new("res://assets/game/key/$t/frameGlitch.png")
static var OUTLINE_MASK:KeyTextureLoader = KeyTextureLoader.new("res://assets/game/key/$t/outlineMask.png")

const CURSE_FILL_DARK:Texture2D = preload("res://assets/game/key/curse/fillDark.png")

const SIGNFLIP_SYMBOL:Texture2D = preload("res://assets/game/key/symbols/signflip.png")
const POSROTOR_SYMBOL:Texture2D = preload("res://assets/game/key/symbols/posrotor.png")
const NEGROTOR_SYMBOL:Texture2D = preload("res://assets/game/key/symbols/negrotor.png")
const INFINITE_SYMBOL:Texture2D = preload("res://assets/game/key/symbols/infinite.png")

static var TEXTURE:KeyColorsTextureLoader = KeyColorsTextureLoader.new("res://assets/game/key/$c/$t.png", TEXTURE_COLORS, true, false, {capitalised=false})
static var GLITCH:KeyColorsTextureLoader = KeyColorsTextureLoader.new("res://assets/game/key/$c/glitch$t.png", TEXTURE_COLORS, false, false, {capitalised=true})

const FKEYBULK:Font = preload("res://resources/fonts/fKeyBulk.fnt")

const CREATE_PARAMETERS:Array[StringName] = [
	&"position"
]
const PROPERTIES:Array[StringName] = [
	&"id", &"position", &"size",
	&"color", &"type", &"count", &"infinite", &"un"
]
static var ARRAYS:Dictionary[StringName,GDScript] = {}

var color:Game.COLOR = Game.COLOR.WHITE
var type:TYPE = TYPE.NORMAL
var count:C = C.ONE
var infinite:bool = false
var un:bool = false # whether a star or curse key is an unstar or uncurse key

var drawDropShadow:RID
var drawGlitch:RID
var drawMain:RID
var drawSymbol:RID
func _init() -> void: size = Vector2(32,32)

func _ready() -> void:
	drawDropShadow = RenderingServer.canvas_item_create()
	drawGlitch = RenderingServer.canvas_item_create()
	drawMain = RenderingServer.canvas_item_create()
	drawSymbol = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_material(drawGlitch,Game.GLITCH_MATERIAL.get_rid())
	RenderingServer.canvas_item_set_z_index(drawDropShadow,-3)
	RenderingServer.canvas_item_set_parent(drawDropShadow,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawGlitch,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawMain,get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawSymbol,get_canvas_item())
	Game.connect(&"goldIndexChanged",func():if color in Game.ANIMATED_COLORS: queue_redraw())

func outlineTex() -> Texture2D: return getOutlineTexture(color, type, un)

static func getOutlineTexture(keyColor:Game.COLOR, keyType:TYPE=TYPE.NORMAL, keyUn:bool=false) -> Texture2D:
	var textureType:KeyTextureLoader.TYPE = keyTextureType(keyType,keyUn)
	match keyColor:
		Game.COLOR.MASTER:
			match textureType:
				KeyTextureLoader.TYPE.NORMAL: return preload("res://assets/game/key/master/outlineMask.png")
				KeyTextureLoader.TYPE.EXACT: return preload("res://assets/game/key/master/outlineMaskExact.png")
		Game.COLOR.QUICKSILVER:
			match textureType:
				KeyTextureLoader.TYPE.NORMAL: return preload("res://assets/game/key/quicksilver/outlineMask.png")
				KeyTextureLoader.TYPE.EXACT: return preload("res://assets/game/key/quicksilver/outlineMaskExact.png")
		Game.COLOR.DYNAMITE:
			if textureType == KeyTextureLoader.TYPE.NORMAL: return preload("res://assets/game/key/dynamite/outlineMask.png")
	return OUTLINE_MASK.current([textureType])

func _draw() -> void:
	RenderingServer.canvas_item_clear(drawDropShadow)
	RenderingServer.canvas_item_clear(drawGlitch)
	RenderingServer.canvas_item_clear(drawMain)
	RenderingServer.canvas_item_clear(drawSymbol)
	if !active and Game.playState == Game.PLAY_STATE.PLAY: return
	var rect:Rect2 = Rect2(Vector2.ZERO, size)
	RenderingServer.canvas_item_add_texture_rect(drawDropShadow,Rect2(Vector2(3,3),size),getOutlineTexture(color,type,un),false,Game.DROP_SHADOW_COLOR)
	drawKey(drawGlitch,drawMain,Vector2.ZERO,color,type,un,glitchMimic)
	if animState == ANIM_STATE.FLASH: RenderingServer.canvas_item_add_texture_rect(drawSymbol,rect,outlineTex(),false,Color(Color.WHITE,animAlpha))
	match type:
		KeyBulk.TYPE.NORMAL, KeyBulk.TYPE.EXACT:
			if !count.eq(1): TextDraw.outlined2(FKEYBULK,drawSymbol,str(count),keycountColor(),keycountOutlineColor(),14,Vector2(1,25))
		KeyBulk.TYPE.ROTOR:
			if count.eq(-1): RenderingServer.canvas_item_add_texture_rect(drawSymbol,rect,SIGNFLIP_SYMBOL)
			elif count.eq(C.I): RenderingServer.canvas_item_add_texture_rect(drawSymbol,rect,POSROTOR_SYMBOL)
			elif count.eq(C.nI): RenderingServer.canvas_item_add_texture_rect(drawSymbol,rect,NEGROTOR_SYMBOL)
	if infinite: RenderingServer.canvas_item_add_texture_rect(drawSymbol,rect,INFINITE_SYMBOL)

func keycountColor() -> Color: return Color("#363029") if count.sign() < 0 else Color("#ebe3dd")
func keycountOutlineColor() -> Color: return Color("#d6cfc9") if count.sign() < 0 else Color("#363029")

static func keyTextureType(keyType:TYPE, keyUn:bool) -> KeyTextureLoader.TYPE:
	match keyType:
		TYPE.EXACT: return KeyTextureLoader.TYPE.EXACT
		TYPE.STAR: return KeyTextureLoader.TYPE.UNSTAR if keyUn else KeyTextureLoader.TYPE.STAR
		TYPE.CURSE: return KeyTextureLoader.TYPE.UNCURSE if keyUn else KeyTextureLoader.TYPE.CURSE
		_: return KeyTextureLoader.TYPE.NORMAL

static func drawKey(keyDrawGlitch:RID,keyDrawMain:RID,keyOffset:Vector2,keyColor:Game.COLOR,keyType:TYPE=TYPE.NORMAL,keyUn:bool=false,keyGlitchMimic:Game.COLOR=Game.COLOR.GLITCH) -> void:
	var rect:Rect2 = Rect2(keyOffset, Vector2(32,32))
	var textureType:KeyTextureLoader.TYPE = keyTextureType(keyType, keyUn)
	if keyColor in TEXTURE_COLORS:
		RenderingServer.canvas_item_add_texture_rect(keyDrawMain,rect,TEXTURE.current([keyColor,textureType]))
	elif keyColor == Game.COLOR.GLITCH:
		RenderingServer.canvas_item_add_texture_rect(keyDrawGlitch,rect,FRAME_GLITCH.current([textureType]))
		RenderingServer.canvas_item_add_texture_rect(keyDrawGlitch,rect,FILL.current([textureType]),false,Game.mainTone[keyColor])
		if keyType == TYPE.CURSE: RenderingServer.canvas_item_add_texture_rect(keyDrawGlitch,rect,CURSE_FILL_DARK,false,Game.darkTone[keyColor])
		if keyGlitchMimic != Game.COLOR.GLITCH:
			if keyGlitchMimic in TEXTURE_COLORS: RenderingServer.canvas_item_add_texture_rect(keyDrawMain,rect,GLITCH.current([keyGlitchMimic,textureType]))
			else: RenderingServer.canvas_item_add_texture_rect(keyDrawMain,rect,FILL_GLITCH.current([textureType]),false,Game.mainTone[keyGlitchMimic])
	else:
		RenderingServer.canvas_item_add_texture_rect(keyDrawMain,rect,FRAME.current([textureType]))
		RenderingServer.canvas_item_add_texture_rect(keyDrawMain,rect,FILL.current([textureType]),false,Game.mainTone[keyColor])
		if keyType == TYPE.CURSE and !keyUn: RenderingServer.canvas_item_add_texture_rect(keyDrawMain,rect,CURSE_FILL_DARK,false,Game.darkTone[keyColor])

func propertyChangedInit(property:StringName) -> void:
	if property == &"type":
		if type not in [TYPE.NORMAL, TYPE.EXACT] and count.neq(1): Changes.addChange(Changes.PropertyChange.new(self,&"count",C.ONE))
		if type == TYPE.ROTOR and (count.abs().neq(1) or count.eq(1)): Changes.addChange(Changes.PropertyChange.new(self,&"count",C.nONE))
		if type not in [TYPE.STAR, TYPE.CURSE] and un: Changes.addChange(Changes.PropertyChange.new(self,&"un",false))

# ==== PLAY ==== #
var glitchMimic:Game.COLOR = Game.COLOR.GLITCH

enum ANIM_STATE {IDLE, FLASH}
var animState:ANIM_STATE = ANIM_STATE.IDLE
var animAlpha:float = 0

func _process(delta:float) -> void:
	match animState:
		ANIM_STATE.IDLE: animAlpha = 0
		ANIM_STATE.FLASH:
			animAlpha -= delta*6
			if animAlpha <= 0: animState = ANIM_STATE.IDLE
			queue_redraw()

func stop() -> void:
	glitchMimic = Game.COLOR.GLITCH
	super()

func collect(player:Player) -> void:
	match type:
		TYPE.NORMAL: GameChanges.addChange(GameChanges.KeyChange.new(effectiveColor(), player.key[effectiveColor()].plus(count)))
		TYPE.EXACT: GameChanges.addChange(GameChanges.KeyChange.new(effectiveColor(), count))
		TYPE.ROTOR: GameChanges.addChange(GameChanges.KeyChange.new(effectiveColor(), player.key[effectiveColor()].times(count)))
		TYPE.STAR: GameChanges.addChange(GameChanges.StarChange.new(effectiveColor(), !un))
		TYPE.CURSE: GameChanges.addChange(GameChanges.CurseChange.new(effectiveColor(), !un))
		
	if infinite: flashAnimation()
	else: GameChanges.addChange(GameChanges.PropertyChange.new(self, &"active", false))
	GameChanges.bufferSave()

	if color == Game.COLOR.MASTER: # not effectiveColor; doesnt trigger on glitch master
		AudioManager.play(preload("res://resources/sounds/key/master.wav"))
	else:
		match type:
			TYPE.ROTOR: AudioManager.play(preload("res://resources/sounds/key/signflip.wav"))
			TYPE.STAR:
				if un: AudioManager.play(preload("res://resources/sounds/key/unstar.wav"))
				else: AudioManager.play(preload("res://resources/sounds/key/star.wav"))
			_:
				if count.sign() < 0: AudioManager.play(preload("res://resources/sounds/key/negative.wav"))
				else: AudioManager.play(preload("res://resources/sounds/key/normal.wav"))

func setGlitch(setColor:Game.COLOR) -> void:
	GameChanges.addChange(GameChanges.PropertyChange.new(self, &"glitchMimic", setColor))
	queue_redraw()

func flashAnimation() -> void:
	animState = ANIM_STATE.FLASH
	animAlpha = 1

func propertyGameChangedDo(property:StringName) -> void:
	if property == &"active":
		%interact.process_mode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED


func effectiveColor() -> Game.COLOR:
	if color == Game.COLOR.GLITCH: return glitchMimic
	return color
