extends Sprite2D
class_name KeyParticle

var speed:float
var direction:float
var rotationSpeed:float = 5
var alpha:float = 1

func _init(_position:Vector2,index:int,color:Color,speedMult:float) -> void:
	position = _position
	direction = 3.8830085198*index # tau * 0.618 (hello phi)
	rotation = randf_range(0,TAU)
	speed = randf_range(2,8)
	var size:float = 0.5+(speed-3)/5
	scale = Vector2(size,size)
	speed *= speedMult
	modulate = color
	texture = preload("res://assets/game/goal/keyParticle.png")

func _physics_process(_delta:float) -> void:
	speed = max(0, speed - 0.03)
	rotationSpeed = max(0, rotationSpeed - 0.1)
	position += Vector2(speed,0).rotated(direction)
	rotation += deg_to_rad(rotationSpeed)
	if speed <= 0.1:
		alpha = max(0, alpha - 0.02)
		modulate.a = alpha
		if alpha == 0: queue_free()	
