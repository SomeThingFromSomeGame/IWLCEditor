extends HBoxContainer
class_name ComplexNumberEdit

@onready var editor:Editor = get_node("/root/editor")
@onready var realEdit:NumberEdit = %realEdit
@onready var imaginaryEdit:NumberEdit = %imaginaryEdit

signal valueSet(value:PackedInt64Array)

var value:PackedInt64Array

func setValue(_value:PackedInt64Array,manual:bool=false) -> void:
	value = _value
	realEdit.setValue(M.r(value), true)
	imaginaryEdit.setValue(M.ir(value), true)

	if !manual: valueSet.emit(value)

func _realSet(r:PackedInt64Array) -> void:
	setValue(M.Ncn(r,M.ir(value)))

func _imaginarySet(i:PackedInt64Array) -> void:
	setValue(M.Ncn(M.r(value),i))

func rotate() -> void:
	setValue(M.rotate(value))
