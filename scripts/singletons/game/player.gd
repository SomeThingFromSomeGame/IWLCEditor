extends CharacterBody2D
class_name Player

const HELD_SHINE:Texture2D = preload("res://assets/game/player/held/shine.png")
func getMasterShineColor() -> Color: return Color("#b4b432") if M.positive(sign(masterMode)) else Color("#3232b4")

const HELD_MASTER:Texture2D = preload("res://assets/game/player/held/master.png")
const HELD_QUICKSILVER:Texture2D = preload("res://assets/game/player/held/quicksilver.png")
const HELD_MASTER_NEGATIVE:Texture2D = preload("res://assets/game/player/held/masterNegative.png")
const HELD_QUICKSILVER_NEGATIVE:Texture2D = preload("res://assets/game/player/held/quicksilverNegative.png")
func getHeldKeySprite() -> Texture2D:
	if masterCycle == 1: return HELD_MASTER if M.positive(sign(masterMode)) else HELD_MASTER_NEGATIVE
	else: return HELD_QUICKSILVER if M.positive(sign(masterMode)) else HELD_QUICKSILVER_NEGATIVE

const AURA_RED:Texture2D = preload("res://assets/game/player/aura/red.png")
const AURA_GREEN:Texture2D = preload("res://assets/game/player/aura/green.png")
const AURA_BLUE:Texture2D = preload("res://assets/game/player/aura/blue.png")
const AURA_MAROON:Texture2D = preload("res://assets/game/player/aura/maroon.png")
const AURA_FOREST:Texture2D = preload("res://assets/game/player/aura/forest.png")
const AURA_NAVY:Texture2D = preload("res://assets/game/player/aura/navy.png")
const AURA_DRAW_OPACITY:Color = Color(Color.WHITE,0.5)
const AURA_RECT:Rect2 = Rect2(Vector2(-32,-32),Vector2(64,64))

const FPS:float = 60 # godot velocity works in /s so we account for gamemaker's fps, which is 60

const JUMP_SPEED:float = 8.5
const DOUBLE_JUMP_SPEED:float = 7
const GRAVITY:float = 0.4
const Y_MAXSPEED:float = 9

var canDoubleJump:bool = true
var key:Array[PackedInt64Array] = []
var star:Array[bool]
var curse:Array[bool]

var cantSave:bool = false # cant save if near a door

var masterMode:PackedInt64Array = M.ZERO
var masterCycle:int = 0 # 0 = None, 1 = Master, 2 = Silver
const MASTER_CYCLE_COLORS:Array[Game.COLOR] = [Game.COLOR.WHITE, Game.COLOR.MASTER, Game.COLOR.QUICKSILVER]

var complexMode:PackedInt64Array = M.ONE # C(1,0) for real view, C(0,1) for i-view

var drawDropShadow:RID

var drawMasterShine:RID
var drawMasterKey:RID
var masterShineAngle:float = 0

var pauseFrame:bool = true # jank prevention

var auraRed:bool = false
var auraGreen:bool = false
var auraBlue:bool = false
var auraMaroon:bool = false
var auraForest:bool = false
var auraNavy:bool = false
var drawAura:RID

var explodey:bool = false

var curseMode:int = 0 # 0 = none, 1 = curse, -1 = uncurse
var curseColor:Game.COLOR
var drawCurse:CurseParticle

var drawComplexModeText:RID
var drawComplexSwitch:RID
var complexSwitchAnim:bool = false
var complexSwitchAngle:float = 0

var previousPosition:Vector2
var previousIsOnFloor:bool

const WARP_1:Texture2D = preload("res://assets/game/player/lily/warp1.png")
const WARP_2:Texture2D = preload("res://assets/game/player/lily/warp2.png")
var drawWarp:RID
var crashAnimAngle:float = 0
var crashAnimHue:float = 0
var crashAnimSat:float = 0
var crashAnimVal:float = 0

func _ready() -> void:
	drawDropShadow = RenderingServer.canvas_item_create()
	drawWarp = RenderingServer.canvas_item_create()
	drawAura = RenderingServer.canvas_item_create()
	drawMasterShine = RenderingServer.canvas_item_create()
	drawMasterKey = RenderingServer.canvas_item_create()
	drawComplexModeText = RenderingServer.canvas_item_create()
	drawComplexSwitch = RenderingServer.canvas_item_create()
	drawCurse = CurseParticle.new(curseColor,curseMode)
	RenderingServer.canvas_item_set_material(drawMasterShine, Game.ADDITIVE_MATERIAL)
	RenderingServer.canvas_item_set_material(drawComplexSwitch, Game.ADDITIVE_MATERIAL)
	drawCurse.z_index = 4
	RenderingServer.canvas_item_set_z_index(drawDropShadow,-3)
	RenderingServer.canvas_item_set_z_index(drawWarp,2)
	RenderingServer.canvas_item_set_z_index(drawAura,6)
	RenderingServer.canvas_item_set_z_index(drawMasterShine,6)
	RenderingServer.canvas_item_set_z_index(drawMasterKey,6)
	RenderingServer.canvas_item_set_z_index(drawComplexModeText,6)
	RenderingServer.canvas_item_set_z_index(drawComplexSwitch,6)
	RenderingServer.canvas_item_set_parent(drawDropShadow, get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawWarp, get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawAura, get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawMasterShine, get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawMasterKey, get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawComplexModeText, get_canvas_item())
	RenderingServer.canvas_item_set_parent(drawComplexSwitch, get_canvas_item())
	add_child(drawCurse)

	for color in Game.COLORS:
		# if color == Game.COLOR.STONE:
		key.append(M.ZERO)
		star.append(false)
		curse.append(color == Game.COLOR.BROWN)
	
	previousPosition = position
	previousIsOnFloor = is_on_floor()

func paused() -> bool:
	return Game.playState != Game.PLAY_STATE.PLAY or (Game.playGame and (Game.playGame.inAnimation() or Game.playGame.paused)) or Game.won or Game.crashState

func _physics_process(_delta:float) -> void:
	if paused():
		if Game.won: visible = false
		else: %sprite.pause()
		return
	
	var xSpeed:float = 6
	if Input.is_action_pressed(&"gameWalk"): xSpeed = 1
	elif !is_on_floor() or (Input.is_action_pressed(&"gameRun") == Game.autoRun): xSpeed = 3
	var moveDirection:float = Input.get_axis(&"gameLeft", &"gameRight")
	velocity.x = xSpeed*FPS*moveDirection

	if pauseFrame:
		pauseFrame = false
	else:
		cantSave = false
		for area in %near.get_overlapping_areas(): near(area)
		for area in %interact.get_overlapping_areas(): interacted(area)
		GameChanges.process()
		previousPosition = position
		previousIsOnFloor = is_on_floor()

	var onAnything:bool = Game.tiles in %floor.get_overlapping_bodies()
	var onOpeningDoor:bool = false
	for area in %floor.get_overlapping_areas():
		if area.get_parent() is Door:
			if area.get_parent().type == Door.TYPE.COMBO or !area.get_parent().justOpened: onAnything = true
			else: onOpeningDoor = true
	if is_on_floor() and onAnything:
		canDoubleJump = true

	if Input.is_action_just_pressed(&"gameJump"):
		if onAnything or onOpeningDoor:
			velocity.y = -JUMP_SPEED*FPS
			AudioManager.play(preload("res://resources/sounds/player/jump.wav"))
			if !onAnything:
				velocity.y *= 0.45
				canDoubleJump = false
		elif canDoubleJump:
			velocity.y = -DOUBLE_JUMP_SPEED*FPS
			canDoubleJump = false
			AudioManager.play(preload("res://resources/sounds/player/doubleJump.wav"))
	if Input.is_action_just_released(&"gameJump") and velocity.y < 0 and !Game.fullJumps: velocity.y *= 0.45
	velocity.y += GRAVITY*FPS
	velocity.y = clamp(velocity.y, -Y_MAXSPEED*FPS, Y_MAXSPEED*FPS)

	move_and_slide()

	if moveDirection: %sprite.flip_h = moveDirection < 0

	if velocity.y <= -0.05*FPS: %sprite.play("jump")
	elif velocity.y >= 0.05*FPS: %sprite.play("fall")
	elif moveDirection: %sprite.play("run")
	else: %sprite.play("idle")

func _process(delta:float) -> void:
	masterShineAngle += delta*4.1887902048 # 4 degrees per frame, 60fps
	masterShineAngle = fmod(masterShineAngle,TAU)
	if complexSwitchAnim:
		complexSwitchAngle += delta*5.2359877560 # 5 degrees per frame, 60fps
		if complexSwitchAngle >= 1.5707963268: complexSwitchAnim = false
	if Game.crashState:
		crashAnimAngle += delta*4.7123889804 # 4.5 degrees per frame, 60fps
		crashAnimHue += delta*2.3529411765
		if crashAnimHue >= 1: crashAnimHue -= 1
		crashAnimVal = min(crashAnimHue+15*delta,1)
		crashAnimSat = min(crashAnimSat+1.5*delta,1)
	queue_redraw()

	drawCurse.mode = curseMode
	drawCurse.color = curseColor
	drawCurse.queue_redraw()

func receiveKey(event:InputEventKey):
	if paused(): return
	if Editor.eventIs(event, &"editPausePlaytest") and Game.editor: Game.pauseTest()
	elif Editor.eventIs(event, &"editStopPlaytest") and Game.editor: Game.stopTest()
	elif Editor.eventIs(event, &"gameRestart"): Game.restart()
	elif Editor.eventIs(event, &"gameUndo") and GameChanges.undo(): AudioManager.play(preload("res://resources/sounds/player/undo.wav"), 1, 0.6)
	elif Editor.eventIs(event, &"gameAction"): cycleMaster()
	elif Editor.eventIs(event, &"gameComplexSwitch"): complexSwitch()
	match event.keycode:
		KEY_U: print(GameChanges.undoStack)

func _newlyInteracted(area:Area2D) -> void:
	if pauseFrame: return
	var object:GameObject = area.get_parent()
	if object is KeyBulk: object.collect(self)
	elif object is RemoteLock: object.check(self)
	elif object is Door and object.type == Door.TYPE.GATE: checkKeys()
	elif object is Goal: Game.win(object)

func _newlyUninteracted(area: Area2D):
	if pauseFrame: return
	var object:GameObject = area.get_parent()
	if object is Door and object.type == Door.TYPE.GATE: checkKeys()

func interacted(area:Area2D) -> void:
	var object:GameObject = area.get_parent()
	if object is Door:
		if object.justOpened: object.justOpened = false
		object.tryOpen(self)
	elif object is KeyBulk:
		cantSave = true

func near(area:Area2D) -> void:
	var object:GameObject = area.get_parent()
	if object is Door:
		cantSave = true
		object.auraCheck(self)
		if curseMode: object.curseCheck(self)
	if object is RemoteLock:
		cantSave = true
		object.auraCheck(self)
		if curseMode: object.curseCheck(self)

func overlapping(area:Area2D) -> bool: return %interact.overlaps_area(area)

func cycleMaster() -> void:
	var armamentImmunities:Array[Game.COLOR] = getArmamentImmunities()

	if masterCycle < 1 and Game.COLOR.MASTER not in armamentImmunities: # MASTER
		var relevantCount:PackedInt64Array = M.across(key[Game.COLOR.MASTER], complexMode)
		if M.ex(relevantCount):
			masterCycle = 1
			masterMode = M.axis(relevantCount)
			if M.positive(M.sign(relevantCount)): AudioManager.play(preload("res://resources/sounds/player/masterEquip.wav"))
			else: AudioManager.play(preload("res://resources/sounds/player/masterNegativeEquip.wav"))
			return
	if masterCycle < 2 and Game.COLOR.QUICKSILVER not in armamentImmunities: # QUICKSILVER
		var relevantCount:PackedInt64Array = M.across(key[Game.COLOR.MASTER], complexMode)
		if M.ex(relevantCount):
			masterCycle = 2
			masterMode = M.axis(relevantCount)
			if M.positive(M.sign(relevantCount)): AudioManager.play(preload("res://resources/sounds/player/masterEquip.wav"))
			else: AudioManager.play(preload("res://resources/sounds/player/masterNegativeEquip.wav"))
			return
	if masterCycle != 0:
		AudioManager.play(preload("res://resources/sounds/player/masterUnequip.wav"))
	dropMaster()

func dropMaster() -> void:
	masterMode = M.ZERO
	masterCycle = 0

func getArmamentImmunities() -> Array[Game.COLOR]:
	var colors:Array[Game.COLOR] = []
	for area in %interact.get_overlapping_areas():
		var object = area.get_parent()
		if object is Door and object.type == Door.TYPE.GATE:
			for color in object.armamentColors():
				if color not in colors: colors.append(color)
	return colors

func checkKeys() -> void:
	var armamentImmunities:Array[Game.COLOR] = getArmamentImmunities()

	if !M.positive(M.reduce(M.sign(M.across(key[MASTER_CYCLE_COLORS[masterCycle]],masterMode)))) or MASTER_CYCLE_COLORS[masterCycle] in armamentImmunities: dropMaster()

	auraRed = M.positive(key[Game.COLOR.RED]) and M.gte(M.sub(key[Game.COLOR.RED], key[Game.COLOR.MAROON]), M.N(1)) and Game.COLOR.RED not in armamentImmunities
	auraGreen = M.positive(key[Game.COLOR.GREEN]) and M.gte(M.sub(key[Game.COLOR.GREEN], key[Game.COLOR.FOREST]), M.N(5)) and Game.COLOR.GREEN not in armamentImmunities
	auraBlue = M.positive(key[Game.COLOR.BLUE]) and M.gte(M.sub(key[Game.COLOR.BLUE], key[Game.COLOR.NAVY]), M.N(3)) and Game.COLOR.BLUE not in armamentImmunities
	auraMaroon = M.positive(key[Game.COLOR.MAROON]) and M.gte(M.sub(key[Game.COLOR.MAROON], key[Game.COLOR.RED]), M.N(1)) and Game.COLOR.MAROON not in armamentImmunities
	auraForest = M.positive(key[Game.COLOR.FOREST]) and M.gte(M.sub(key[Game.COLOR.FOREST], key[Game.COLOR.GREEN]), M.N(5)) and Game.COLOR.FOREST not in armamentImmunities
	auraNavy = M.positive(key[Game.COLOR.NAVY]) and M.gte(M.sub(key[Game.COLOR.NAVY], key[Game.COLOR.BLUE]), M.N(3)) and Game.COLOR.NAVY not in armamentImmunities

	explodey = M.ex(key[Game.COLOR.DYNAMITE]) and Game.COLOR.DYNAMITE not in armamentImmunities

	curseMode = 0
	var highestSeen:PackedInt64Array = M.ZERO
	if Game.COLOR.PURE not in armamentImmunities:
		for color in Game.COLORS:
			if !curse[color] or M.nex(M.r(key[color])) or color in armamentImmunities: continue
			# tie
			if M.eq(M.abs(M.r(key[color])), highestSeen): curseMode = 0
			elif M.gt(M.abs(M.r(key[color])), highestSeen):
				highestSeen = M.abs(M.r(key[color]))
				curseMode = M.toInt(M.sign(M.r(key[color])))
				curseColor = color as Game.COLOR

func complexSwitch() -> void:
	if M.eq(complexMode, M.ONE): complexMode = M.I
	else: complexMode = M.ONE

	AudioManager.play(preload("res://resources/sounds/player/camera.wav"))
	AudioManager.play(preload("res://resources/sounds/key/signflip.wav"))
	complexSwitchAnim = true
	complexSwitchAngle = 0

	if M.eq(complexMode, M.I) and masterCycle and M.ex(M.i(key[MASTER_CYCLE_COLORS[masterCycle]])):
		masterMode = M.axis(M.i(key[MASTER_CYCLE_COLORS[masterCycle]]))
	elif M.eq(complexMode, M.ONE) and masterCycle and M.ex(M.r(key[MASTER_CYCLE_COLORS[masterCycle]])):
		masterMode = M.axis(M.r(key[MASTER_CYCLE_COLORS[masterCycle]]))
	elif masterCycle:
		AudioManager.play(preload("res://resources/sounds/player/masterUnequip.wav"))
		dropMaster()
	for object in Game.objects.values(): if object is Door: object.complexCheck()
	for component in Game.components.values(): if component is Lock: component.queue_redraw()

func crashAnim() -> void:
	%sprite.visible = false
	crashAnimAngle = 0
	crashAnimHue = 0
	crashAnimSat = 0
	crashAnimVal = 0.3137254902

func _draw() -> void:
	RenderingServer.canvas_item_clear(drawDropShadow)
	RenderingServer.canvas_item_clear(drawWarp)
	RenderingServer.canvas_item_clear(drawAura)
	RenderingServer.canvas_item_clear(drawMasterShine)
	RenderingServer.canvas_item_clear(drawMasterKey)
	RenderingServer.canvas_item_clear(drawComplexModeText)
	RenderingServer.canvas_item_clear(drawComplexSwitch)
	# warps
	if Game.crashState:
		var offset:int = int(12*sin(crashAnimAngle))
		RenderingServer.canvas_item_add_texture_rect(drawWarp,Rect2(Vector2(-16+offset,-23),Vector2(32,32)),WARP_1,false,Color.from_hsv(crashAnimHue,crashAnimSat,crashAnimVal))
		RenderingServer.canvas_item_add_texture_rect(drawWarp,Rect2(Vector2(-16-offset,-23),Vector2(32,32)),WARP_2,false,Color.from_hsv(crashAnimHue,crashAnimSat,crashAnimVal))
		return
	# drop shadow
	RenderingServer.canvas_item_add_texture_rect(drawDropShadow,Rect2(Vector2(-13,-20),Vector2(-32 if %sprite.flip_h else 32,32)),%sprite.sprite_frames.get_frame_texture(%sprite.animation,%sprite.frame),false,Game.DROP_SHADOW_COLOR)
	# auras
	if auraRed: RenderingServer.canvas_item_add_texture_rect(drawAura,AURA_RECT,AURA_RED,false,AURA_DRAW_OPACITY)
	if auraMaroon: RenderingServer.canvas_item_add_texture_rect(drawAura,AURA_RECT,AURA_MAROON,false,AURA_DRAW_OPACITY)
	if auraGreen: RenderingServer.canvas_item_add_texture_rect(drawAura,AURA_RECT,AURA_GREEN,false,AURA_DRAW_OPACITY)
	if auraForest: RenderingServer.canvas_item_add_texture_rect(drawAura,AURA_RECT,AURA_FOREST,false,AURA_DRAW_OPACITY)
	if auraBlue: RenderingServer.canvas_item_add_texture_rect(drawAura,AURA_RECT,AURA_BLUE,false,AURA_DRAW_OPACITY)
	if auraNavy: RenderingServer.canvas_item_add_texture_rect(drawAura,AURA_RECT,AURA_NAVY,false,AURA_DRAW_OPACITY)
	# held
	if masterCycle != 0:
		var masterShineScale:float = 0.8 + 0.2*sin(masterShineAngle)
		var masterDrawOpacity:Color = Color(Color.WHITE,masterShineScale*0.6)
		RenderingServer.canvas_item_add_texture_rect(drawMasterShine,Rect2(Vector2(-32,-32)*masterShineScale,Vector2(64,64)*masterShineScale),HELD_SHINE,false,getMasterShineColor())
		RenderingServer.canvas_item_add_texture_rect(drawMasterKey,Rect2(Vector2(-16,-16),Vector2(32,32)),getHeldKeySprite(),false,masterDrawOpacity)
	if M.eq(complexMode, M.I):
		TextDraw.outlinedCentered(Game.FTALK,drawComplexModeText,"I-View",Color.from_hsv(Game.complexViewHue,0.4901960784,1),Color.BLACK,12,Vector2(0,-10))
	# complex switch
	if complexSwitchAnim:
		var switchScale:float = sin(complexSwitchAngle)
		RenderingServer.canvas_item_add_texture_rect(drawComplexSwitch,Rect2(Vector2(-64*switchScale,-64*switchScale),Vector2(128*switchScale,128*switchScale)),CurseParticle.TEXTURE_GENERIC,false,Color(Color.WHITE,cos(complexSwitchAngle)))
