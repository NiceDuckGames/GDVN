@tool
extends Node

# Godot Variant Notation (GDVN)

# GDVN is a notation written on top of JSON
# that provides a consistent conversion between
# Godot Variant types and JSON-supported types.
#
# To solve the problem of easy conversion, the format
# converts Variants to strings by encoding them using
# their constructor's syntax. For example:
#
#
# var vec = Vector2(123, 456)
# var as_string = GDVN.stringify(vec)
# print(as_string)
#
# Output: "Vector2(123, 456)"
#
#
# The strings are converted back into Variants
# using Expressions, which are able to parse the
# constructor of any Variant type.


# List of supported Variant constructors
# Used for validation when converting strings to variants.
var constructor_validation_strings: Array = [
	"Vector2",
	"Vector2i",
	"Vector3",
	"Vector3i",
	"Vector4",
	"Vector4i",
	"Rect2",
	"Rect2i",
	"Plane",
	"Quaternion",
	"Color",
	"int",
	"float",
	"bool"
]


func stringify(data: Variant, indent: String = "    ", sort_keys: bool = false, full_precision: bool = false) -> String:
	
	var gdvn: Variant = stringify_variants(data)
	
	if gdvn is Dictionary || gdvn is Array:
		return JSON.stringify(data, indent, sort_keys, full_precision)
	
	return gdvn


func parse_string(data: String) -> Variant:
	
	if data.begins_with("{") || data.begins_with("["):
		
		var json: Dictionary = JSON.parse_string(data)
		var gdvn: Variant = parse_variant_strings(json)
		
		return gdvn
	
	else:
		
		var gdvn: Variant = parse_variant_strings(data)
		
		return gdvn


# Recursively turn variants into strings representing their constructor syntax
func stringify_variants(data: Variant) -> Variant:
	
	match typeof(data):
		
		TYPE_STRING:
			return data
		
		TYPE_BOOL:
			return "bool(%s)" % data
		
		TYPE_FLOAT:
			return "float(%s)" % data
		
		TYPE_INT:
			return "int(%s)" % data
		
		TYPE_VECTOR2:
			return "Vector2(%s, %s)" % [data.x, data.y]
		
		TYPE_VECTOR2I:
			return "Vector2i(%s, %s)" % [data.x, data.y]
		
		TYPE_VECTOR3:
			return "Vector3(%s, %s, %s)" % [data.x, data.y, data.z]
		
		TYPE_VECTOR3I:
			return "Vector3i(%s, %s, %s)" % [data.x, data.y, data.z]
		
		TYPE_VECTOR4:
			return "Vector4(%s, %s, %s, %s)" % [data.w, data.x, data.y, data.z]
		
		TYPE_VECTOR4I:
			return "Vector4i(%s, %s, %s, %s)" % [data.w, data.x, data.y, data.z]
		
		TYPE_PLANE:
			return "Plane(%s, %s, %s, %s)" % [data.normal.x, data.normal.y, data.normal.z, data.d]
		
		TYPE_QUATERNION:
			return "Quaternion(%s, %s, %s, %s)" % [data.x, data.y, data.z, data.w]
		
		TYPE_RECT2:
			return "Rect2(%s, %s, %s, %s)" % [data.position.x, data.position.y, data.size.x, data.size.y]
		
		TYPE_RECT2I:
			return "Rect2i(%s, %s, %s, %s)" % [data.position.x, data.position.y, data.size.x, data.size.y]
		
		TYPE_COLOR:
			return "Color(%s, %s, %s, %s)" % [data.r, data.g, data.b, data.a]
		
		TYPE_DICTIONARY:
			
			# Convert all the keys
			var new_keys: Dictionary = {}
			
			for key in data.keys():
				new_keys[stringify_variants(key)] = data[key]
				data.erase(key)
			
			data.merge(new_keys)
			
			# Then convert the values
			for k in data:
				data[k] = stringify_variants(data[k])
				
			return data
		
		TYPE_ARRAY:
			for i in data.size():
				data[i] = stringify_variants(data[i])
			return data
	
		_:
			return str(data)


# Recursively convert constructor syntax strings into variants
func parse_variant_strings(data: Variant) -> Variant:
	
	match typeof(data):
		
		TYPE_STRING:
			
			return string_to_variant(data)
		
		TYPE_DICTIONARY:
			
			# Convert all the keys
			var new_keys: Dictionary = {}
			
			for key in data.keys():
				new_keys[parse_variant_strings(key)] = data[key]
				data.erase(key)
			
			data.merge(new_keys)
			
			# Then convert the values
			for k in data:
				data[k] = parse_variant_strings(data[k])
			
			return data
		
		TYPE_ARRAY:
			
			for i in data.size():
				data[i] = parse_variant_strings(data[i])
			return data
		
		_:
			return data


# Convert a single constructor syntax string into a variant
func string_to_variant(data: String) -> Variant:
	
	var splits = data.split("(")
	
	# Do some validation to confirm the correct constructor syntax
	if splits.size() == 2 && splits[1].ends_with(")") && constructor_validation_strings.has(splits[0]):
		
		var exp: Expression = Expression.new()
		var err = exp.parse(data)
		
		if err != OK:
			return data
		
		var value: Variant = exp.execute()
		
		if exp.has_execute_failed():
			return data
		
		return value
	
	return data
