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

# New number
func N(n:int) -> PackedInt64Array:
	return [n, 0]

# New Imaginary number
func Ni(n:int) -> PackedInt64Array:
	return [0, n]

# New Complex number
func Nc(a:int,b:int) -> PackedInt64Array:
	return [a, b]

# New Complex number from Numbers
func Ncn(a:PackedInt64Array,b:PackedInt64Array) -> PackedInt64Array:
	return [a[0], b[0]]

func allAxes() -> PackedInt64Array:
	return [1,1]

# operators

func add(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]+b[0], a[1]+b[1]]

func sub(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]-b[0], a[1]-b[1]]

func times(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]*b[0]-a[1]*b[1], a[0]*b[1]+a[1]*b[0]]

func across(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0]*b[0], a[1]*b[1]]

func divide(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	@warning_ignore("integer_division") return [(a[0]*b[0]+a[1]*b[1])/(b[0]*b[0]+b[1]*b[1]), (a[1]*b[0]-a[0]*b[1])/(b[0]*b[0]+b[1]*b[1])]

func divoss(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	@warning_ignore("integer_division") return [a[0]/b[0], a[1]/b[1]]

func modulo(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [(a[0]*b[0]+a[1]*b[1])%(b[0]*b[0]+b[1]*b[1]), (a[1]*b[0]-a[0]*b[1])%(b[0]*b[0]+b[1]*b[1])]

func along(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array: return across(a, axis(b))
func alongbs(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array: return across(a, axibs(b))

func negate(n:PackedInt64Array) -> PackedInt64Array:
	return [-n[0], -n[1]]

func rotate(n:PackedInt64Array) -> PackedInt64Array:
	return [-n[1], n[0]]

# componentwise max
func max(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [max(a[0], b[0]), max(a[1], b[1])]

# componentwise orelse
func orelse(a:PackedInt64Array, b:PackedInt64Array) -> PackedInt64Array:
	return [a[0] if a[0] else b[0], a[1] if a[1] else b[1]]

# reducers

func r(n:PackedInt64Array) -> PackedInt64Array:
	return [n[0], 0]

func i(n:PackedInt64Array) -> PackedInt64Array:
	return [0 ,n[1]]

func ir(n:PackedInt64Array) -> PackedInt64Array:
	return [n[1], 0]

func sign(n:PackedInt64Array) -> PackedInt64Array:
	return [sign(n[0])+sign(n[1]), 0]

func abs(n:PackedInt64Array) -> PackedInt64Array:
	return [abs(n[0])+abs(n[1]), 0]

func reduce(n:PackedInt64Array) -> PackedInt64Array:
	return [n[0]+n[1], 0]

func axis(n:PackedInt64Array) -> PackedInt64Array:
	return [sign(n[0]), sign(n[1])]

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

func cgt(a:PackedInt64Array, b:PackedInt64Array) -> bool: return gt(a,b) && igt(a,b)
func cgte(a:PackedInt64Array, b:PackedInt64Array) -> bool: return gte(a,b) && igte(a,b)
func clt(a:PackedInt64Array, b:PackedInt64Array) -> bool: return lt(a,b) && ilt(a,b)
func clte(a:PackedInt64Array, b:PackedInt64Array) -> bool: return lte(a,b) && ilte(a,b)

func divisibleBy(a:PackedInt64Array, b:PackedInt64Array) -> bool: return nex(modulo(a,b))

func implies(a:PackedInt64Array, b:PackedInt64Array) -> bool:
	return (a[0] == 0 || b[0] != 0) && (a[1] == 0 || b[1] != 0)

# signed implies
func simplies(a:PackedInt64Array, b:PackedInt64Array) -> bool:
	return (a[0] == 0 || sign(a[0]) == sign(b[0])) && (a[1] == 0 || sign(a[1]) == sign(b[1]))

# deciders

# "exists"
func ex(n:PackedInt64Array) -> bool:
	return neq(n, ZERO)

func nex(n:PackedInt64Array) -> bool:
	return eq(n, ZERO)

func isNonzeroReal(n:PackedInt64Array) -> bool:
	return n[0] and !n[1]

func isNonzeroImag(n:PackedInt64Array) -> bool:
	return !n[0] and n[1]

func isNonzeroAxial(n:PackedInt64Array) -> bool:
	return bool(n[0]) != bool(n[1])

func isComplex(n:PackedInt64Array) -> bool:
	return n[0] and n[1]

func positive(n:PackedInt64Array) -> bool:
	return n[0] > 0

func negative(n:PackedInt64Array) -> bool:
	return n[0] < 0

func nonPositive(n:PackedInt64Array) -> bool:
	return n[0] <= 0

func nonNegative(n:PackedInt64Array) -> bool:
	return n[0] >= 0

func hasPositive(n:PackedInt64Array) -> bool:
	return n[0] > 0 or n[1] > 0

func hasNegative(n:PackedInt64Array) -> bool:
	return n[0] < 0 or n[1] < 0

func hasNonPositive(n:PackedInt64Array) -> bool:
	return n[0] <= 0 or n[1] <= 0

func hasNonNegative(n:PackedInt64Array) -> bool:
	return n[0] >= 0 or n[1] >= 0

# util

func toIpow(n:PackedInt64Array) -> int:
	if eq(n, ONE): return 0
	elif eq(n, I): return 1
	elif eq(n, nONE): return 2
	elif eq(n, nI): return 3
	else: assert(false); return 0

# needs to work for 1 and -1
func toInt(n:PackedInt64Array) -> int:
	return n[0]

func str(n:PackedInt64Array) -> String:
	return strWithInf(n,ZERO)

func strWithInf(n:PackedInt64Array,infAxes:PackedInt64Array) -> String:
	var rComponent:String
	var iComponent:String = ""
	if infAxes[0]: rComponent = "-~" if n[0] < 0 else "~"
	elif n[0]: rComponent = str(n[0])
	if n[1]:
		if n[1] > 0 and n[0]: iComponent += "+"
		if infAxes[1]: iComponent += "-~i" if n[1] < 0 else "~i"
		else: iComponent += str(n[1]) + "i"
	if !n[0] and !n[1]: return "0"
	return rComponent + iComponent

func keepAbove(a:PackedInt64Array,b:PackedInt64Array) -> PackedInt64Array:
	# in both axes, keeps the magnitude of a greater than or equal to the magnitude of b, in the direction of b. if b doesnt exist in that axis, it will be unaffected
	return along(M.max(along(a,orelse(b,allAxes())), acrabs(b)), orelse(b,allAxes()))
