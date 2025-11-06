extends RefCounted
class_name Q

static var ZERO:Q = Q.new(0)
var n:int

func _init(_n:Variant=0) -> void:
	if _n is Q: n = _n.n
	else: n = _n

func _to_string() -> String:
	return str(n)

func copy() -> Q: return Q.new(n)

func neq(number) -> bool: return n != Q.new(number).n
func eq(number) -> bool: return n == Q.new(number).n
func gt(number) -> bool: return n > Q.new(number).n
func lt(number) -> bool: return n < Q.new(number).n

func sign() -> int: return sign(n)

func abs() -> Q: return Q.new(abs(n))

func plus(number) -> Q: return Q.new(n+Q.new(number).n)
func minus(number) -> Q: return Q.new(n-Q.new(number).n)
func times(number) -> Q: return Q.new(n*Q.new(number).n)

func divint(number) -> Q:
	@warning_ignore("integer_division") return Q.new(n/Q.new(number).n)

func squared() -> Q: return self.times(self)

func divides(number) -> bool:
	return n % Q.new(number).n == 0

func _get_property_list() -> Array[Dictionary]:
	return [
		{"name":"n","type":TYPE_INT,"usage":PROPERTY_USAGE_SCRIPT_VARIABLE|PROPERTY_USAGE_STORAGE}
	]
