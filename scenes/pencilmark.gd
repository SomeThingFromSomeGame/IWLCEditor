extends Control
class_name PencilMark

@onready var symbolmark = %SymbolMark
@onready var numbermark = %NumberMark
@onready var textmark = %TextMark


@export var type = 0 ## Pencilmark type. 0 is symbol, 1 is number, 2 is text
## different variables for each type
@export var symbol = 0 ## symbol. 0 through 5
@export var number = 0 ## number. preferrably any integer
@export var message = "pencilmark"

@export var color_id = 0 ## color you can choose in the pencilmark, being the id of the pencilmark menu color thing idk

func _ready() -> void:
	update()


func update() -> void:
	modulate = Game.mainTone[color_id] ## placeholder until i figure out pencilmark menu
	match type:
		0:
			if symbol >= 0 and symbol < 6:
				symbolmark.visible = true
				numbermark.visible = false
				textmark.visible = false
				var _image = load("res://assets/ui/pencilmarks/symbol/symbol"+var_to_str(symbol)+".png")
				symbolmark.get_node("Symbol").texture = _image
				symbolmark.get_node("Symbol/Symbol2").texture = _image
				symbolmark.get_node("Symbol/Symbol3").texture = _image
				symbolmark.get_node("Symbol/Symbol4").texture = _image
				symbolmark.get_node("Symbol/Symbol5").texture = _image
		1:
			symbolmark.visible = false
			numbermark.visible = true
			textmark.visible = false
			var _num = var_to_str(number)
			numbermark.get_node("Label").text = _num
			numbermark.get_node("Label/Label2").text = _num
			numbermark.get_node("Label/Label3").text = _num
			numbermark.get_node("Label/Label4").text = _num
			numbermark.get_node("Label/Label5").text = _num
		2:
			symbolmark.visible = false
			numbermark.visible = false
			textmark.visible = true
			
			textmark.text = message
			textmark.get_node("Label2").text = message
			textmark.get_node("Label3").text = message
			textmark.get_node("Label4").text = message
			textmark.get_node("Label5").text = message
