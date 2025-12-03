extends Node

enum SYSTEM {COMPLEX}
var system:SYSTEM = SYSTEM.COMPLEX

var ZERO:PackedInt64Array:
	get():
		return [0,0]

var ONE:PackedInt64Array:
	get():
		return [1,0]

var nONE:PackedInt64Array:
	get():
		return [-1,0]

var I:PackedInt64Array:
	get():
		return [0,1]

var nI:PackedInt64Array:
	get():
		return [0,-1]

# initialisers

func N(n:int) -> PackedInt64Array:
	return [n, 0]

func Ni(n:int) -> PackedInt64Array:
	return [0, n]

func Nc(a:int,b:int) -> PackedInt64Array:
	return [a, b]

# operators

func add(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]+b[0], a[1]+b[1]]

func sub(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]-b[0], a[1]-b[1]]

func times(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]*b[0]-a[1]*b[1], a[0]*b[1]+a[1]*b[0]]

func across(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]*b[0], a[1]*b[1]]

func divint(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	@warning_ignore("integer_division") return [a[0]/b[0], a[1]/b[1]]

func divide(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	@warning_ignore("integer_division") return [(a[0]*b[0]+a[1]*b[1])/(a[1]*a[1]*b[1]*b[1]), (a[1]*b[0]-a[0]*b[1])/(a[1]*a[1]*b[1]*b[1])]

func modulo(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [(a[0]*b[0]+a[1]*b[1])%(a[1]*a[1]*b[1]*b[1]), (a[1]*b[0]-a[0]*b[1])%(a[1]*a[1]*b[1]*b[1])]

func along(a:PackedInt64Array, bAxial:PackedInt64Array) -> PackedInt64Array:
	return times(a, naxis(bAxial))

# reducers

func r(n:PackedInt64Array) -> PackedInt64Array:
	return [n[0], 0]

func i(n:PackedInt64Array) -> PackedInt64Array:
	return [0 ,n[1]]

func sign(n:PackedInt64Array) -> PackedInt64Array:
	return [sign(n[0])+sign(n[1]), 0]

func abs(n:PackedInt64Array) -> PackedInt64Array:
	return [abs(n[0])+abs(n[1]), 0]

func reduce(n:PackedInt64Array) -> PackedInt64Array:
	return [n[0]+n[1], 0]

func axis(n:PackedInt64Array) -> PackedInt64Array:
	return [sign(n[0]), sign(n[1])]

# "not axis"; n:Axial, naxis(n) = 1/axis(n)
func naxis(n:PackedInt64Array) -> PackedInt64Array:
	return [-sign(n[0]), -sign(n[1])]

# "safe axis"; 1 if would be 0
func saxis(n:PackedInt64Array) -> PackedInt64Array: return axis(n) if n != ZERO else ONE

func acrabs(n:PackedInt64Array) -> PackedInt64Array:
	return [abs(n[0]), abs(n[1])]

func axibs(n:PackedInt64Array) -> PackedInt64Array: return acrabs(axis(n))

# comparators

func eq(a:PackedInt64Array, b:PackedInt64Array) -> bool: return a == b

func neq(a:PackedInt64Array, b:PackedInt64Array) -> bool: return a != b

func gt(a:PackedInt64Array, b:PackedInt64Array) -> bool:
	return a[0] > b[0]

func gte(a:PackedInt64Array, b:PackedInt64Array) -> bool: return !lt(a, b)

func lt(a:PackedInt64Array, b:PackedInt64Array) -> bool:
	return a[0] < b[0]

func lte(a:PackedInt64Array, b:PackedInt64Array) -> bool: return !gt(a, b)

func igt(a:PackedInt64Array, b:PackedInt64Array) -> bool:
	return a[1] > b[1]

func igte(a:PackedInt64Array, b:PackedInt64Array) -> bool: return !ilt(a, b)

func ilt(a:PackedInt64Array, b:PackedInt64Array) -> bool:
	return a[1] < b[1]

func ilte(a:PackedInt64Array, b:PackedInt64Array) -> bool: return !igt(a, b)

# deciders

func isNonzeroReal(n:PackedInt64Array) -> bool:
	return n[0] and !n[1]

func isNonzeroImag(n:PackedInt64Array) -> bool:
	return !n[0] and n[1]

func isNonzeroAxial(n:PackedInt64Array) -> bool:
	return bool(n[0]) != bool(n[1])

func isComplex(n:PackedInt64Array) -> bool:
	return n[0] and n[1]

func positive(n:PackedInt64Array) -> bool:
	return n[0] > 0 and n[1] > 0

func negative(n:PackedInt64Array) -> bool:
	return n[0] < 0 and n[1] < 0

func nonPositive(n:PackedInt64Array) -> bool:
	return n[0] <= 0 and n[1] <= 0

func nonNegative(n:PackedInt64Array) -> bool:
	return n[0] >= 0 and n[1] >= 0

func hasPositive(n:PackedInt64Array) -> bool:
	return n[0] > 0 or n[1] > 0

func hasNegative(n:PackedInt64Array) -> bool:
	return n[0] < 0 or n[1] < 0

func hasNonPositive(n:PackedInt64Array) -> bool:
	return n[0] <= 0 or n[1] <= 0

func hasNonNegative(n:PackedInt64Array) -> bool:
	return n[0] >= 0 or n[1] >= 0

# util

func toIPow(n:PackedInt64Array) -> int:
	if eq(n, ONE): return 0
	elif eq(n, I): return 1
	elif eq(n, nONE): return 2
	elif eq(n, nI): return 3
	else: assert(false); return 0

func str(n:PackedInt64Array) -> String:
	return strWithInf(n,ZERO)

func strWithInf(n:PackedInt64Array,infAxes:PackedInt64Array) -> String:
	var rComponent:String
	var iComponent:String = ""
	if infAxes[0]: rComponent = "-~" if n[0] < 0 else "~"
	elif n[0]: rComponent = str(r)
	if n[1]:
		if n[1] > 0 and n[0]: iComponent += "+"
		if infAxes[1]: iComponent += "-~i" if n[1] < 0 else "~i"
		else: iComponent += str(i) + "i"
	if !n[0] and !n[1]: return "0"
	return rComponent + iComponent
