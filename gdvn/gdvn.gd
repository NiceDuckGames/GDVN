@tool
extends Node

class_name GDVN

## Godot Variant Notation (GDVN)
##
## GDVN is a notation written on top of JSON
## that provides a consistent conversion between
## Godot Variant types and JSON-supported types.
##
## To solve the problem of easy conversion, the format
## converts Variants to strings by encoding them using
## their constructor's syntax. For example:
##
##
## var vec = Vector2(123, 456)
## var as_string = GDVN.stringify(vec)
## print(as_string)
##
## Output: "Vector2(123, 456)"
##
##
## The strings are converted back into Variants
## using Expressions, which are able to parse the
## constructor of any Variant type.


## List of supported Variant constructors
## Used for validation when converting strings to variants.
static var constructor_validation_strings: Array = [
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

var data: Variant
var parsed_text: String
var error_line: int
var error_message: String


## Non-static alternative to `parse_string()`. Returns an Error
## that can be used for custom error handling. The resulting data
## can be retrieved from the `data` member variable.
func parse(gdvn_text: String, keep_text: bool = false) -> Error:
	
	if keep_text: parsed_text = gdvn_text
	
	if gdvn_text.begins_with("{") || gdvn_text.begins_with("["):
		
		var json: JSON = JSON.new()
		var err: Error = json.parse(gdvn_text, keep_text)
		
		error_line = json.get_error_line()
		error_message = json.get_error_message()
		
		if err == OK:
			
			var json_data: Variant = json.data
			data = parse_variant_strings(json_data)
			
			return err
		
		return err
	
	else:
		
		data = parse_variant_strings(gdvn_text)
		
		return OK


## Retrieve the error message from the last `parse()` call.
func get_error_message() -> String:
	return error_message


## Retrieve the error line from the last `parse()` call.
func get_error_line() -> int:
	return error_line


## Return the text that was parsed during the last `parse()` call
## if `keep_text` was true.
func get_parsed_text() -> String:
	return parsed_text


## Converts a Variant to a String represented
## by the Variant's constructor syntax. If `data` is a 
## Dictionary or Array, a JSON formatted String is returned.
static func stringify(variant_data: Variant, indent: String = "    ", sort_keys: bool = false, full_precision: bool = false) -> String:
	
	var gdvn: Variant = stringify_variants(variant_data)
	
	if gdvn is Dictionary || gdvn is Array:
		return JSON.stringify(variant_data, indent, sort_keys, full_precision)
	
	return gdvn


## Converts a String encoded with `stringify()` back into
## its equivalent Variant Type. 
static func parse_string(gdvn_text: String) -> Variant:
	
	if gdvn_text.begins_with("{") || gdvn_text.begins_with("["):
		
		var json: Variant = JSON.parse_string(gdvn_text)
		var gdvn: Variant = parse_variant_strings(json)
		
		return gdvn
	
	else:
		
		var gdvn: Variant = parse_variant_strings(gdvn_text)
		
		return gdvn


## Recursively turn variants into strings representing their constructor syntax
static func stringify_variants(gdvn_text: Variant) -> Variant:
	
	match typeof(gdvn_text):
		
		TYPE_STRING:
			return gdvn_text
		
		TYPE_BOOL:
			return "bool(%s)" % gdvn_text
		
		TYPE_FLOAT:
			return "float(%s)" % gdvn_text
		
		TYPE_INT:
			return "int(%s)" % gdvn_text
		
		TYPE_VECTOR2:
			return "Vector2(%s, %s)" % [gdvn_text.x, gdvn_text.y]
		
		TYPE_VECTOR2I:
			return "Vector2i(%s, %s)" % [gdvn_text.x, gdvn_text.y]
		
		TYPE_VECTOR3:
			return "Vector3(%s, %s, %s)" % [gdvn_text.x, gdvn_text.y, gdvn_text.z]
		
		TYPE_VECTOR3I:
			return "Vector3i(%s, %s, %s)" % [gdvn_text.x, gdvn_text.y, gdvn_text.z]
		
		TYPE_VECTOR4:
			return "Vector4(%s, %s, %s, %s)" % [gdvn_text.w, gdvn_text.x, gdvn_text.y, gdvn_text.z]
		
		TYPE_VECTOR4I:
			return "Vector4i(%s, %s, %s, %s)" % [gdvn_text.w, gdvn_text.x, gdvn_text.y, gdvn_text.z]
		
		TYPE_PLANE:
			return "Plane(%s, %s, %s, %s)" % [gdvn_text.normal.x, gdvn_text.normal.y, gdvn_text.normal.z, gdvn_text.d]
		
		TYPE_QUATERNION:
			return "Quaternion(%s, %s, %s, %s)" % [gdvn_text.x, gdvn_text.y, gdvn_text.z, gdvn_text.w]
		
		TYPE_RECT2:
			return "Rect2(%s, %s, %s, %s)" % [gdvn_text.position.x, gdvn_text.position.y, gdvn_text.size.x, gdvn_text.size.y]
		
		TYPE_RECT2I:
			return "Rect2i(%s, %s, %s, %s)" % [gdvn_text.position.x, gdvn_text.position.y, gdvn_text.size.x, gdvn_text.size.y]
		
		TYPE_COLOR:
			return "Color(%s, %s, %s, %s)" % [gdvn_text.r, gdvn_text.g, gdvn_text.b, gdvn_text.a]
		
		TYPE_DICTIONARY:
			
			# Convert all the keys
			var new_keys: Dictionary = {}
			
			for key in gdvn_text.keys():
				new_keys[stringify_variants(key)] = gdvn_text[key]
				gdvn_text.erase(key)
			
			gdvn_text.merge(new_keys)
			
			# Then convert the values
			for k in gdvn_text:
				gdvn_text[k] = stringify_variants(gdvn_text[k])
				
			return gdvn_text
		
		TYPE_ARRAY:
			for i in gdvn_text.size():
				gdvn_text[i] = stringify_variants(gdvn_text[i])
			return gdvn_text
	
		_:
			return str(gdvn_text)


## Recursively convert constructor syntax strings into variants
static func parse_variant_strings(variant_data: Variant) -> Variant:
	
	match typeof(variant_data):
		
		TYPE_STRING:
			
			return string_to_variant(variant_data)
		
		TYPE_DICTIONARY:
			
			# Convert all the keys
			var new_keys: Dictionary = {}
			
			for key in variant_data.keys():
				new_keys[parse_variant_strings(key)] = variant_data[key]
				variant_data.erase(key)
			
			variant_data.merge(new_keys)
			
			# Then convert the values
			for k in variant_data:
				variant_data[k] = parse_variant_strings(variant_data[k])
			
			return variant_data
		
		TYPE_ARRAY:
			
			for i in variant_data.size():
				variant_data[i] = parse_variant_strings(variant_data[i])
			return variant_data
		
		_:
			return variant_data


## Convert a single constructor syntax string into a variant
static func string_to_variant(gdvn_text: String) -> Variant:
	
	var splits = gdvn_text.split("(")
	
	# Do some validation to confirm the correct constructor syntax
	if splits.size() == 2 && splits[1].ends_with(")") && constructor_validation_strings.has(splits[0]):
		
		var exp: Expression = Expression.new()
		var err = exp.parse(gdvn_text)
		
		if err != OK:
			return gdvn_text
		
		var value: Variant = exp.execute()
		
		if exp.has_execute_failed():
			return gdvn_text
		
		return value
	
	return gdvn_text
